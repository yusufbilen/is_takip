import 'package:flutter/material.dart';
import '../services/share_service.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';
import '../models/etkinlik.dart';

class ShareButton extends StatelessWidget {
  final Widget child;
  final Muvekkil? muvekkil;
  final Dava? dava;
  final List<Gorev>? gorevler;
  final List<Etkinlik>? etkinlikler;
  final VoidCallback? onPressed;

  const ShareButton({
    super.key,
    required this.child,
    this.muvekkil,
    this.dava,
    this.gorevler,
    this.etkinlikler,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: child,
      onSelected: (value) => _handleShare(context, value),
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    if (muvekkil != null) {
      items.add(
        const PopupMenuItem(
          value: 'muvekkil',
          child: ListTile(
            leading: Icon(Icons.person, color: Color(0xFF1E3A8A)),
            title: Text('Müvekkil Bilgilerini Paylaş'),
            dense: true,
          ),
        ),
      );
    }

    if (dava != null) {
      items.addAll([
        const PopupMenuItem(
          value: 'dava_text',
          child: ListTile(
            leading: Icon(Icons.folder, color: Color(0xFF3B82F6)),
            title: Text('Dava Bilgilerini Paylaş'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'dava_pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
            title: Text('Dava Raporu (PDF)'),
            dense: true,
          ),
        ),
      ]);
    }

    if (gorevler != null && gorevler!.isNotEmpty) {
      items.add(
        const PopupMenuItem(
          value: 'gorevler',
          child: ListTile(
            leading: Icon(Icons.task, color: Color(0xFFF59E0B)),
            title: Text('Görev Listesini Paylaş'),
            dense: true,
          ),
        ),
      );
    }

    if (etkinlikler != null && etkinlikler!.isNotEmpty) {
      items.add(
        const PopupMenuItem(
          value: 'etkinlikler',
          child: ListTile(
            leading: Icon(Icons.event, color: Color(0xFF374151)),
            title: Text('Etkinlik Listesini Paylaş'),
            dense: true,
          ),
        ),
      );
    }

    if (items.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }

    items.add(
      const PopupMenuItem(
        value: 'genel_rapor',
        child: ListTile(
          leading: Icon(Icons.assessment, color: Color(0xFF10B981)),
          title: Text('Genel Rapor'),
          dense: true,
        ),
      ),
    );

    return items;
  }

  Future<void> _handleShare(BuildContext context, String value) async {
    final shareService = ShareService();

    try {
      switch (value) {
        case 'muvekkil':
          if (muvekkil != null) {
            await shareService.shareMuvekkil(muvekkil!);
          }
          break;
        case 'dava_text':
          if (dava != null) {
            await shareService.shareDava(dava!);
          }
          break;
        case 'dava_pdf':
          if (dava != null) {
            await shareService.shareDavaReport(dava!);
          }
          break;
        case 'gorevler':
          if (gorevler != null && gorevler!.isNotEmpty) {
            await shareService.shareGorevList(gorevler!);
          }
          break;
        case 'etkinlikler':
          if (etkinlikler != null && etkinlikler!.isNotEmpty) {
            await shareService.shareEtkinlikList(etkinlikler!);
          }
          break;
        case 'genel_rapor':
          // Bu durumda provider'dan tüm verileri almalıyız
          // Şimdilik basit bir mesaj gösterelim
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Genel rapor özelliği yakında eklenecek'),
              backgroundColor: Color(0xFFF59E0B),
            ),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım sırasında hata oluştu: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}

class ShareButtonSimple extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const ShareButtonSimple({
    super.key,
    required this.onPressed,
    this.icon = Icons.share,
    this.tooltip = 'Paylaş',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: const Color(0xFF1E3A8A),
    );
  }
}

class ShareFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShareFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.share),
      label: const Text('Paylaş'),
    );
  }
}
