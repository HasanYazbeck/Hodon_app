import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/models/child_profile.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

// Simple in-memory provider for children (replace with backend repository)
final childrenProvider = StateProvider<List<ChildProfile>>((ref) => [
      ChildProfile(
        id: 'child_1',
        parentId: 'user_parent_1',
        name: 'Layla',
        ageMonths: 24,
        ageGroup: ChildAgeGroup.toddler,
        allergies: 'Peanuts',
        createdAt: DateTime(2024, 1, 1),
      ),
      ChildProfile(
        id: 'child_2',
        parentId: 'user_parent_1',
        name: 'Adam',
        ageMonths: 60,
        ageGroup: ChildAgeGroup.preschool,
        createdAt: DateTime(2024, 1, 1),
      ),
    ]);

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/parent/add-child'),
          ),
        ],
      ),
      body: children.isEmpty
          ? EmptyState(
              icon: Icons.child_care_rounded,
              title: 'No children added',
              subtitle: 'Add your children\'s profiles to book care',
              action: ElevatedButton(
                onPressed: () => context.push('/parent/add-child'),
                child: const Text('Add Child'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.pageHorizontal),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (_, i) => _ChildCard(child: children[i]),
            ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  final ChildProfile child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return HodonCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Center(
              child: Text(
                child.ageGroup == ChildAgeGroup.baby ? '👶' :
                child.ageGroup == ChildAgeGroup.toddler ? '🧒' :
                child.ageGroup == ChildAgeGroup.preschool ? '👦' : '🧑',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${child.ageDisplay} · ${child.ageGroup.label}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                ),
                if (child.allergies != null && child.allergies!.isNotEmpty)
                  Text(
                    '⚠️ ${child.allergies}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 18, color: hintColor),
            onPressed: () => context.push('/parent/edit-child/${child.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Child Profile'),
        content: Text('Delete ${child.name}\'s profile? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final children = ref.read(childrenProvider);
    ref.read(childrenProvider.notifier).state = [
      for (final current in children)
        if (current.id != child.id) current,
    ];
  }
}

class AddChildScreen extends ConsumerStatefulWidget {
  final String? childId;
  const AddChildScreen({super.key, this.childId});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _routinesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ChildAgeGroup _selectedAgeGroup = ChildAgeGroup.toddler;
  bool _isSaving = false;

  bool get _isEditMode => widget.childId != null;

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    if (!_isEditMode) return;
    final existing = ref
        .read(childrenProvider)
        .where((c) => c.id == widget.childId)
        .firstOrNull;
    if (existing == null) return;

    _nameCtrl.text = existing.name;
    _ageCtrl.text = existing.ageMonths.toString();
    _allergiesCtrl.text = existing.allergies ?? '';
    _routinesCtrl.text = existing.routines ?? '';
    _notesCtrl.text = existing.notes ?? '';
    _selectedAgeGroup = existing.ageGroup;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ageMonths = int.tryParse(_ageCtrl.text) ?? 12;
    final baseChild = _isEditMode
        ? ref
            .read(childrenProvider)
            .where((c) => c.id == widget.childId)
            .firstOrNull
        : null;

    final child = ChildProfile(
      id: baseChild?.id ?? 'child_${DateTime.now().millisecondsSinceEpoch}',
      parentId: baseChild?.parentId ?? 'user_parent_1',
      name: _nameCtrl.text.trim(),
      ageMonths: ageMonths,
      ageGroup: _selectedAgeGroup,
      allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
      routines: _routinesCtrl.text.trim().isEmpty ? null : _routinesCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: baseChild?.createdAt ?? DateTime.now(),
    );

    final children = ref.read(childrenProvider);
    if (_isEditMode) {
      ref.read(childrenProvider.notifier).state = [
        for (final current in children)
          if (current.id == child.id) child else current,
      ];
    } else {
      ref.read(childrenProvider.notifier).state = [...children, child];
    }

    setState(() => _isSaving = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Child' : 'Add Child'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: "Child's Name",
                hint: 'e.g. Layla',
                controller: _nameCtrl,
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Age (in months)',
                hint: 'e.g. 24',
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Age is required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              Text('Age Group', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                children: ChildAgeGroup.values.map((a) => ChoiceChip(
                  label: Text(a.label),
                  selected: _selectedAgeGroup == a,
                  onSelected: (_) => setState(() => _selectedAgeGroup = a),
                  selectedColor: AppColors.primaryContainer,
                )).toList(),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Allergies',
                hint: 'e.g. Peanuts, Dairy (optional)',
                controller: _allergiesCtrl,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Routines',
                hint: 'Nap time, meal schedule...',
                controller: _routinesCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Special Notes',
                hint: 'Any important information for the sitter...',
                controller: _notesCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: _isEditMode ? 'Update Child' : 'Save Child',
                onPressed: _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}
