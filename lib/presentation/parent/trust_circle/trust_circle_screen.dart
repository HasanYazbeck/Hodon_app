import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/models/models.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';

final trustCircleProvider = StateProvider<List<TrustCircleMember>>((ref) => [
      TrustCircleMember(
        id: 'tc_1',
        parentId: 'user_parent_1',
        userId: 'user_sitter_3',
        name: 'Rima Azar',
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
        memberType: TrustCircleMemberType.babysitter,
        isHodonUser: true,
        addedAt: DateTime(2025, 1, 10),
      ),
      TrustCircleMember(
        id: 'tc_2',
        parentId: 'user_parent_1',
        name: 'Teta Fatima',
        memberType: TrustCircleMemberType.relative,
        isHodonUser: false,
        addedAt: DateTime(2025, 2, 5),
      ),
    ]);

class TrustCircleScreen extends ConsumerStatefulWidget {
  const TrustCircleScreen({super.key});

  @override
  ConsumerState<TrustCircleScreen> createState() => _TrustCircleScreenState();
}

class _TrustCircleScreenState extends ConsumerState<TrustCircleScreen> {
  bool _trustCircleFirst = true;

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(trustCircleProvider);
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Circle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showInviteSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explainer card
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSizes.sm),
                  Text('Your Trusted Network', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'During emergency bookings, your Trust Circle is notified first. Only if no one responds do we reach out to the broader sitter pool.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Trust Circle First toggle
            HodonCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(Icons.priority_high_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trust Circle First', style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          'Always notify my circle before others',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _trustCircleFirst,
                    onChanged: (v) => setState(() => _trustCircleFirst = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            SectionHeader(
              title: '${members.length} Members',
              actionLabel: 'Invite',
              onAction: () => _showInviteSheet(context),
            ),
            const SizedBox(height: AppSizes.sm),

            if (members.isEmpty)
              EmptyState(
                icon: Icons.people_outline_rounded,
                title: 'Your circle is empty',
                subtitle: 'Invite trusted babysitters, relatives, or friends',
                action: ElevatedButton(
                  onPressed: () => _showInviteSheet(context),
                  child: const Text('Invite Someone'),
                ),
              )
            else
              ...members.map((m) => _MemberCard(
                    member: m,
                    onRemove: () {
                      ref.read(trustCircleProvider.notifier).state =
                          [...ref.read(trustCircleProvider)]..removeWhere((x) => x.id == m.id);
                    },
                  )),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pageHorizontal,
          AppSizes.lg,
          AppSizes.pageHorizontal,
          AppSizes.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite to Trust Circle', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.lg),
            const AppTextField(label: 'Email or Phone', hint: 'Enter email or phone number'),
            const SizedBox(height: AppSizes.md),
            AppButton(label: 'Send Invite', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TrustCircleMember member;
  final VoidCallback onRemove;

  const _MemberCard({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: HodonCard(
        child: Row(
          children: [
            UserAvatar(imageUrl: member.avatarUrl, name: member.name, size: AppSizes.avatarMd),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: Theme.of(context).textTheme.titleSmall),
                  Row(
                    children: [
                      StatusChip(
                        label: member.memberType.name,
                        color: AppColors.primary,
                      ),
                      if (member.isHodonUser) ...[
                        const SizedBox(width: 6),
                        StatusChip(label: 'Hodon User', color: AppColors.badgeVerified),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

