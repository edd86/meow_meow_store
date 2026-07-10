import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/utils/qr_utils.dart';

class ProductQrDialog extends StatefulWidget {
  final String productName;
  final String qrValue;

  const ProductQrDialog({
    super.key,
    required this.productName,
    required this.qrValue,
  });

  @override
  State<ProductQrDialog> createState() => _ProductQrDialogState();
}

class _ProductQrDialogState extends State<ProductQrDialog> {
  final _qrKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadQr() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await QrUtils.captureWidget(_qrKey);
      final fileName =
          'qr_${QrUtils.sanitizeFileName(widget.productName)}.png';
      final file = await QrUtils.saveToTempFile(bytes, fileName: fileName);

      if (!mounted) return;
      await QrUtils.shareFile(file, subject: 'QR de ${widget.productName}');
    } catch (e) {
      if (mounted) {
        context.showAppSnackBar(
          'Error al generar la imagen QR.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = widget.qrValue.trim();
    final isEmpty = value.isEmpty;
    final isNumericOnly = QrUtils.isNumericOnly(value);
    final canGenerateQr = QrUtils.canGenerateQr(widget.qrValue);

    return Container(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'QR de ${widget.productName}',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2_outlined,
                    size: 96,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Este producto no tiene codigo asignado.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else if (isNumericOnly)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 96,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Este es un codigo de barras numerico y no se puede generar como imagen QR.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: widget.qrValue,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.productName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canGenerateQr ? _downloadQr : null,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label:
                  Text(_isDownloading ? 'Generando...' : 'Descargar imagen'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
