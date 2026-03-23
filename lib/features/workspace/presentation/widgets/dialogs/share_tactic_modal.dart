import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_radius.dart';

/// Share strategy modal (ui_stitch clutch_map_share_tactic_modal).
class ShareTacticModal extends StatefulWidget {
  const ShareTacticModal({
    super.key,
    required this.shareUrl,
    this.onCopyLink,
    this.onInvite,
    this.onDone,
  });

  final String shareUrl;
  final VoidCallback? onCopyLink;
  final void Function(String email)? onInvite;
  final VoidCallback? onDone;

  static Future<void> show(
    BuildContext context, {
    required String shareUrl,
    VoidCallback? onCopyLink,
    void Function(String email)? onInvite,
    VoidCallback? onDone,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => ShareTacticModal(
        shareUrl: shareUrl,
        onCopyLink: onCopyLink,
        onInvite: onInvite,
        onDone: onDone,
      ),
    );
  }

  @override
  State<ShareTacticModal> createState() => _ShareTacticModalState();
}

class _ShareTacticModalState extends State<ShareTacticModal> {
  bool _publicAccess = true;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.shareUrl));
    widget.onCopyLink?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _publicAccessToggle(),
                      const SizedBox(height: 32),
                      _privateLinkSection(),
                      const SizedBox(height: 32),
                      _squadMembersSection(),
                      const SizedBox(height: 24),
                      _inviteByEmail(),
                    ],
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.share, size: 28, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            'Share Strategy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _publicAccessToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PUBLIC ACCESS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anyone with the link can view this tactic',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          Switch(
            value: _publicAccess,
            onChanged: (v) => setState(() => _publicAccess = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _privateLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRIVATE LINK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'SECURE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral900,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: SelectableText(
                          widget.shareUrl,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.white54),
                      onPressed: _copyLink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Viewer',
                dropdownColor: AppColors.neutralSurface,
                style: TextStyle(fontSize: 14, color: Colors.white70),
                items: const [
                  DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                  DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                  DropdownMenuItem(value: 'Commenter', child: Text('Commenter')),
                ],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _copyLink,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Copy Link'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _squadMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SQUAD MEMBERS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutral900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Owner', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Owner', style: TextStyle(fontSize: 12, color: Colors.white54)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inviteByEmail() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Invite by email address...',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.neutral900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  widget.onInvite?.call(v.trim());
                  _emailController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isNotEmpty) {
                widget.onInvite?.call(email);
                _emailController.clear();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              widget.onDone?.call();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
