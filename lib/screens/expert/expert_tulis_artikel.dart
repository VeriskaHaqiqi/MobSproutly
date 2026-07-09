import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/article_provider.dart';
import '../../models/article_model.dart';
//import 'expert_artikel.dart';
import '../../utils/image_helper.dart';
import '../../utils/article_content_parser.dart';

const Color kTulisMain = Color(0xFF5DCFCF);
const Color kTulisTeal = Color(0xFF76EAD0);
const Color kTulisBlue = Color(0xFF76D7EA);
const Color kTulisLGreen = Color(0xFFD0FF99);
const Color kTulisScaffold = Color(0xFFF0F4F3);

// ─── Text Segment (per format chunk) ─────────────────────────────────────────
class TextSegment {
  String text;
  bool isBold;
  bool isItalic;
  bool isUnderline;
  String? linkUrl;

  TextSegment({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.linkUrl,
  });

  TextSegment copy() => TextSegment(
        text: text,
        isBold: isBold,
        isItalic: isItalic,
        isUnderline: isUnderline,
        linkUrl: linkUrl,
      );
}

// ─── Editor Section: either text or image ────────────────────────────────────
enum SectionType { text, image }

class EditorSection {
  SectionType type;
  // text section
  TextEditingController? ctrl;
  FocusNode? focus;
  List<TextSegment> segments;
  // image section
  String? imagePath;

  EditorSection.text()
      : type = SectionType.text,
        segments = [TextSegment(text: '')],
        ctrl = TextEditingController(),
        focus = FocusNode();

    EditorSection.image(String path)
      : type = SectionType.image,
        imagePath = path,
        segments = [];

  void dispose() {
    ctrl?.dispose();
    focus?.dispose();
  }

  String get plainText => segments.map((s) => s.text).join();
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertTulisArtikelPage extends StatefulWidget {
  const ExpertTulisArtikelPage({super.key});

  @override
  State<ExpertTulisArtikelPage> createState() => ExpertTulisArtikelPageState();
}

class ExpertTulisArtikelPageState extends State<ExpertTulisArtikelPage> {
  XFile? coverImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController titleCtrl = TextEditingController();
  String? titleErr;
  int? selectedCategoryId;
  //String selectedCategory = 'Ornamental Plants';
  bool isUploading = false;

  // Multi-section editor
  final List<EditorSection> sections = [EditorSection.text()];
  int focusedSectionIndex = 0;

  // Toolbar state
  bool toolbarBold = false;
  bool toolbarItalic = false;
  bool toolbarUnderline = false;
  bool hasSelection = false;

  @override
  void initState() {
    super.initState();
    _attachSectionListener(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false).fetchCategories();
    });
  }

  void _attachSectionListener(int i) {
    final sec = sections[i];
    if (sec.type != SectionType.text || sec.ctrl == null) return;
    sec.ctrl!.addListener(() => _onSectionChanged(i));
  }

  void _onSectionChanged(int i) {
    if (i >= sections.length) return;
    final sec = sections[i];
    if (sec.type != SectionType.text || sec.ctrl == null) return;
    final sel = sec.ctrl!.selection;
    final hasValidSel = sel.isValid && !sel.isCollapsed;
    setState(() {
      focusedSectionIndex = i;
      hasSelection = hasValidSel;
      // Sync plain text back to segments
      _syncSegmentsFromCtrl(i);
      if (hasValidSel) {
        final seg = _segmentAt(i, sel.start);
        if (seg != null) {
          toolbarBold = seg.isBold;
          toolbarItalic = seg.isItalic;
          toolbarUnderline = seg.isUnderline;
        }
      }
    });
  }

  void _syncSegmentsFromCtrl(int i) {
    final sec = sections[i];
    if (sec.type != SectionType.text || sec.ctrl == null) return;
    final newText = sec.ctrl!.text;
    final oldText = sec.plainText;
    if (newText == oldText) return;

    // Simple sync: rebuild segments preserving format by char mapping
    if (sec.segments.isEmpty) {
      sec.segments.add(TextSegment(text: newText));
      return;
    }

    // Map old char positions to segments
    final newSegs = <TextSegment>[];
    int pos = 0;
    for (final seg in sec.segments) {
      final segEnd = pos + seg.text.length;
      if (pos >= newText.length) break;
      final end = segEnd < newText.length ? segEnd : newText.length;
      final slice = newText.substring(pos, end);
      if (slice.isNotEmpty) {
        newSegs.add(TextSegment(
          text: slice,
          isBold: seg.isBold,
          isItalic: seg.isItalic,
          isUnderline: seg.isUnderline,
          linkUrl: seg.linkUrl,
        ));
      }
      pos = segEnd;
    }
    // Remaining new text
    if (pos < newText.length) {
      newSegs.add(TextSegment(text: newText.substring(pos)));
    }

    sec.segments.clear();
    sec.segments
        .addAll(newSegs.isEmpty ? [TextSegment(text: newText)] : newSegs);
  }

  TextSegment? _segmentAt(int sectionIdx, int offset) {
    final sec = sections[sectionIdx];
    int pos = 0;
    for (final seg in sec.segments) {
      if (offset >= pos && offset < pos + seg.text.length) return seg;
      pos += seg.text.length;
    }
    return sec.segments.isNotEmpty ? sec.segments.last : null;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    for (final s in sections) {
      s.dispose();
    }
    super.dispose();
  }

  // ── Format apply ─────────────────────────────────────────────────────────
  void applyFormat(String fmt) {
    final i = focusedSectionIndex;
    if (i >= sections.length) return;
    final sec = sections[i];
    if (sec.type != SectionType.text || sec.ctrl == null) return;

    final sel = sec.ctrl!.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final start = sel.start;
    final end = sel.end;
    final full = sec.ctrl!.text;

    final newSegs = <TextSegment>[];
    int pos = 0;

    for (final seg in sec.segments) {
      final segEnd = pos + seg.text.length;

      if (segEnd <= start || pos >= end) {
        if (seg.text.isNotEmpty) newSegs.add(seg.copy());
      } else {
        if (pos < start) {
          newSegs.add(TextSegment(
            text: full.substring(pos, start),
            isBold: seg.isBold,
            isItalic: seg.isItalic,
            isUnderline: seg.isUnderline,
            linkUrl: seg.linkUrl,
          ));
        }
        final selStart = start > pos ? start : pos;
        final selEnd = end < segEnd ? end : segEnd;
        final selected = seg.copy();
        selected.text = full.substring(selStart, selEnd);
        if (fmt == 'bold') selected.isBold = !toolbarBold;
        if (fmt == 'italic') selected.isItalic = !toolbarItalic;
        if (fmt == 'underline') selected.isUnderline = !toolbarUnderline;
        if (selected.text.isNotEmpty) newSegs.add(selected);

        if (segEnd > end) {
          newSegs.add(TextSegment(
            text: full.substring(end, segEnd),
            isBold: seg.isBold,
            isItalic: seg.isItalic,
            isUnderline: seg.isUnderline,
            linkUrl: seg.linkUrl,
          ));
        }
      }
      pos = segEnd;
    }

    // Merge same-format adjacent
    final merged = <TextSegment>[];
    for (final s in newSegs) {
      if (merged.isNotEmpty &&
          merged.last.isBold == s.isBold &&
          merged.last.isItalic == s.isItalic &&
          merged.last.isUnderline == s.isUnderline &&
          merged.last.linkUrl == s.linkUrl) {
        merged.last.text += s.text;
      } else {
        merged.add(s);
      }
    }

    setState(() {
      sec.segments.clear();
      sec.segments.addAll(merged.isEmpty ? [TextSegment(text: '')] : merged);
      if (fmt == 'bold') toolbarBold = !toolbarBold;
      if (fmt == 'italic') toolbarItalic = !toolbarItalic;
      if (fmt == 'underline') toolbarUnderline = !toolbarUnderline;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sec.ctrl!.selection = TextSelection(baseOffset: start, extentOffset: end);
    });
  }

  // ── Insert link ───────────────────────────────────────────────────────────
  void insertLink() {
    final i = focusedSectionIndex;
    final sec = sections[i];
    if (sec.type != SectionType.text || sec.ctrl == null) return;

    final urlCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    final sel = sec.ctrl!.selection;
    if (sel.isValid && !sel.isCollapsed) {
      textCtrl.text = sec.ctrl!.text.substring(sel.start, sel.end);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Insert Link',
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(textCtrl, 'Display text'),
            const SizedBox(height: 12),
            _dialogField(urlCtrl, 'URL (https://...)', type: TextInputType.url),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlCtrl.text.trim();
              final text = textCtrl.text.trim();
              if (url.isEmpty) return;
              Navigator.pop(ctx);
              final display = text.isEmpty ? url : text;
              _insertLinkInSection(i, display, url, sel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kTulisMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Insert',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _insertLinkInSection(
      int i, String display, String url, TextSelection sel) {
    final sec = sections[i];
    final ctrl = sec.ctrl!;
    final full = ctrl.text;

    int start, end;
    if (sel.isValid && !sel.isCollapsed) {
      start = sel.start;
      end = sel.end;
    } else {
      start = end = sel.isValid ? sel.baseOffset : full.length;
    }

    final before = full.substring(0, start);
    final after = full.substring(end);
    final newText = before + display + after;

    setState(() {
      sec.segments.clear();
      if (before.isNotEmpty) sec.segments.add(TextSegment(text: before));
      sec.segments
          .add(TextSegment(text: display, isUnderline: true, linkUrl: url));
      if (after.isNotEmpty) sec.segments.add(TextSegment(text: after));
    });

    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + display.length),
    );
  }

  Widget _dialogField(TextEditingController c, String label,
      {TextInputType? type}) {
    return TextField(
      controller: c,
      keyboardType: type,
      style: GoogleFonts.outfit(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kTulisMain, width: 1.5)),
      ),
    );
  }

  // ── Insert image ──────────────────────────────────────────────────────────
  Future<void> insertImage() async {
    try {
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      setState(() {
        final imgSec = EditorSection.image(file.path);
        final textSec = EditorSection.text();
        final insertAt = focusedSectionIndex + 1;
        sections.insert(insertAt, imgSec);
        sections.insert(insertAt + 1, textSec);
        _attachSectionListener(insertAt + 1);
        focusedSectionIndex = insertAt + 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sections[focusedSectionIndex].focus?.requestFocus();
      });
    } catch (_) {}
  }

  void deleteSection(int i) {
    setState(() {
      sections[i].dispose();
      sections.removeAt(i);
      if (sections.isEmpty) {
        sections.add(EditorSection.text());
        _attachSectionListener(0);
      }
      focusedSectionIndex = focusedSectionIndex.clamp(0, sections.length - 1);
    });
  }

  // ── Cover ─────────────────────────────────────────────────────────────────
  Future<void> pickCover() async {
    try {
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) setState(() => coverImage = file);
    } catch (_) {}
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void handleUpload() async {
    setState(() {
      titleErr =
          titleCtrl.text.trim().isEmpty ? 'Article title is required' : null;
    });
    if (titleErr != null) return;

    setState(() => isUploading = true);
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);

    final contentBuffer = StringBuffer();
    for (final s in sections) {
      if (s.type == SectionType.text && s.ctrl != null) {
        contentBuffer.write(s.ctrl!.text);
      } else if (s.type == SectionType.image && s.imagePath != null) {
        final path = await articleProvider.uploadContentImage(s.imagePath!);
        if (path != null) {
          contentBuffer.write('\n${ArticleContentParser.imageMarker(path)}\n');
        }
        // If the upload fails, that image is silently skipped so the
        // rest of the article can still be posted.
      }
    }
    final content = contentBuffer.toString().trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please write some content before uploading.',
            style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      setState(() => isUploading = false);
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a category', style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: Colors.redAccent,
      ));
      setState(() => isUploading = false);
      return;
    }

    final success = await articleProvider.createArticle(
      categoryId: selectedCategoryId!,
      title: titleCtrl.text.trim(),
      content: content,
      coverImagePath: coverImage?.path,
    );

    setState(() => isUploading = false);

    if (success) {
      showSuccessDialog();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(articleProvider.errorMessage ?? 'Failed to upload article.',
            style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kTulisTeal, kTulisMain],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kTulisMain.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text('Article Uploaded!',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 10),
              Text(
                'Your article has been published and is now visible in Articles and My Articles.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.6),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kTulisBlue, kTulisMain],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: kTulisMain.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Text('Back to Articles',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTulisScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCoverPicker(),
                  const SizedBox(height: 20),
                  buildCategoryPicker(),
                  const SizedBox(height: 16),
                  buildTitleField(),
                  const SizedBox(height: 16),
                  buildToolbar(),
                  const SizedBox(height: 8),
                  buildBodyEditor(),
                  const SizedBox(height: 24),
                  buildUploadButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kTulisBlue, kTulisTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text('Write Article',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCoverPicker() {
    return GestureDetector(
      onTap: pickCover,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: coverImage != null ? kTulisMain : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: coverImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ImageHelper.fromPath(coverImage!.path,
                    fit: BoxFit.cover, width: double.infinity))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text('Upload Cover Image',
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Tap to select from gallery',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
      ),
    );
  }

  Widget buildCategoryPicker() {
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, _) {
        final categories = articleProvider.categories; // List<ArticleCategory> dari API

        // Set default kalau selectedCategoryId belum ke-set & data udah kepanggil
        if (categories.isNotEmpty && selectedCategoryId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => selectedCategoryId = categories.first.id);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  isDense: true,
                ),
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCategoryId = val);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Article Title',
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: titleErr != null ? Colors.redAccent : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: titleCtrl,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter article title',
              hintStyle:
                  GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
        if (titleErr != null) ...[
          const SizedBox(height: 4),
          Text(titleErr!,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          // Format buttons — only active when text is selected
          _toolbarTextBtn(
            label: 'B',
            isActive: toolbarBold,
            isEnabled: hasSelection,
            isBoldLabel: true,
            onTap: () => applyFormat('bold'),
          ),
          _toolbarTextBtn(
            label: 'I',
            isActive: toolbarItalic,
            isEnabled: hasSelection,
            isItalicLabel: true,
            onTap: () => applyFormat('italic'),
          ),
          _toolbarTextBtn(
            label: 'U',
            isActive: toolbarUnderline,
            isEnabled: hasSelection,
            isUnderlineLabel: true,
            onTap: () => applyFormat('underline'),
          ),
          // Hint label
          if (!hasSelection)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text('Select text to format',
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: Colors.grey.shade400)),
            ),
          const Spacer(),
          // Link & image always available
          _toolbarIconBtn(
            icon: Icons.link_rounded,
            isActive: false,
            onTap: insertLink,
            tooltip: 'Insert link',
          ),
          _toolbarIconBtn(
            icon: Icons.image_outlined,
            isActive: false,
            onTap: insertImage,
            tooltip: 'Insert image',
          ),
        ],
      ),
    );
  }

  Widget _toolbarTextBtn({
    required String label,
    required bool isActive,
    required bool isEnabled,
    required VoidCallback onTap,
    bool isBoldLabel = false,
    bool isItalicLabel = false,
    bool isUnderlineLabel = false,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive && isEnabled ? kTulisMain : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: isBoldLabel ? FontWeight.w800 : FontWeight.w500,
              fontStyle: isItalicLabel ? FontStyle.italic : FontStyle.normal,
              color: isEnabled
                  ? (isActive ? Colors.white : Colors.black87)
                  : Colors.grey.shade300,
              decoration: isUnderlineLabel
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarIconBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? kTulisMain : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 20, color: isActive ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget buildBodyEditor() {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.asMap().entries.map((entry) {
          final i = entry.key;
          final sec = entry.value;
          if (sec.type == SectionType.image) {
            return _buildImageSection(i, sec);
          } else {
            return _buildTextSection(i, sec);
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTextSection(int i, EditorSection sec) {
    return GestureDetector(
      onTap: () {
        setState(() {
          focusedSectionIndex = i;
          hasSelection = false;
        });
        sec.focus?.requestFocus();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Stack(
          children: [
            // Visible RichText (non-editable, rendered on top)
            if (sec.ctrl!.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: IgnorePointer(
                  child: RichText(
                    text: TextSpan(
                      children: sec.segments
                          .map((seg) => TextSpan(
                                text: seg.text,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: seg.linkUrl != null
                                      ? kTulisMain
                                      : Colors.black87,
                                  fontWeight: seg.isBold
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  fontStyle: seg.isItalic
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  decoration: seg.isUnderline
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                  decorationColor: seg.linkUrl != null
                                      ? kTulisMain
                                      : Colors.black87,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            // Actual editable TextField (transparent when has text)
            TextField(
              controller: sec.ctrl,
              focusNode: sec.focus,
              maxLines: null,
              onChanged: (_) => _onSectionChanged(i),
              onTap: () {
                setState(() {
                  focusedSectionIndex = i;
                  hasSelection = false;
                });
              },
              style: GoogleFonts.outfit(
                fontSize: 14,
                height: 1.6,
                // Transparent when has content so RichText overlay shows
                color: sec.ctrl!.text.isEmpty
                    ? Colors.black87
                    : Colors.transparent,
              ),
              cursorColor: kTulisMain,
              decoration: InputDecoration(
                hintText: i == 0 && sections.length == 1
                    ? 'Start writing your article...'
                    : '',
                hintStyle: GoogleFonts.outfit(
                    fontSize: 14, color: Colors.grey.shade400, height: 1.6),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(int i, EditorSection sec) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ImageHelper.fromPath(sec.imagePath!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => deleteSection(i),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadButton() {
    return GestureDetector(
      onTap: isUploading ? null : handleUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUploading
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [kTulisBlue, kTulisMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUploading
              ? []
              : [
                  BoxShadow(
                      color: kTulisMain.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text('Uploading...',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              )
            : Text('Upload Article',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
      ),
    );
  }
}