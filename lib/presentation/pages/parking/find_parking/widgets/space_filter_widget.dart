import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SpaceFilterWidget extends StatefulWidget {
  final Function(String? section, String? level, String? type) onFilterChanged;

  const SpaceFilterWidget({super.key, required this.onFilterChanged});

  @override
  State<SpaceFilterWidget> createState() => _SpaceFilterWidgetState();
}

class _SpaceFilterWidgetState extends State<SpaceFilterWidget> with SingleTickerProviderStateMixin {
  String? selectedSection;
  String? selectedLevel;
  String? selectedType;
  bool isExpanded = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  final List<String> sections = ['A', 'B', 'C', 'D'];
  final List<String> levels = ['G', '1', '2', '3'];
  final List<String> types = ['Regular', 'Compact', 'Handicapped', 'Electric'];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // Setup animations
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to check if all three filters have been selected
  bool get isFilterComplete {
    return selectedSection != null && selectedLevel != null && selectedType != null;
  }

  // Helper method for filter changes that also checks for auto-closing
  void applyFilters() {
    widget.onFilterChanged(selectedSection, selectedLevel, selectedType);

    // Auto-close the filter if all three selections are made
    if (isFilterComplete) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          isExpanded = false;
        });
        _animationController.reverse();
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });

    if (isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        boxShadow: [if (isExpanded) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter header with expand/collapse
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Animated icon rotation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(color: isFilterComplete ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(4),
                    child:
                        isFilterComplete
                            ? Icon(MdiIcons.checkCircle, color: theme.colorScheme.onPrimary, size: 20)
                            : RotationTransition(turns: _rotationAnimation, child: Icon(MdiIcons.filterVariant, size: 20, color: theme.colorScheme.onSurface)),
                  ),
                  const SizedBox(width: 8),
                  Text('Filter Spaces', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  // Animated rotation
                  RotationTransition(turns: _rotationAnimation, child: Icon(MdiIcons.chevronDown)),
                ],
              ),
            ),
          ),

          // Show active filters summary when collapsed but filters are applied
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (!isExpanded && (selectedSection != null || selectedLevel != null || selectedType != null)) ? 56 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedSection != null)
                      _buildAnimatedChip(
                        'Section: $selectedSection',
                        () {
                          setState(() {
                            selectedSection = null;
                          });
                          applyFilters();
                        },
                        theme.colorScheme.primary,
                        theme.colorScheme.onPrimary,
                      ),
                    if (selectedLevel != null)
                      _buildAnimatedChip(
                        'Level: $selectedLevel',
                        () {
                          setState(() {
                            selectedLevel = null;
                          });
                          applyFilters();
                        },
                        theme.colorScheme.secondary,
                        theme.colorScheme.onSecondary,
                      ),
                    if (selectedType != null)
                      _buildAnimatedChip(
                        'Type: ${selectedType!.substring(0, 1).toUpperCase()}${selectedType!.substring(1)}',
                        () {
                          setState(() {
                            selectedType = null;
                          });
                          applyFilters();
                        },
                        theme.colorScheme.tertiary,
                        theme.colorScheme.onTertiary,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable filter options with animation
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Section filter
                            Text('Section:', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('All'),
                                    selected: selectedSection == null,
                                    selectedColor: theme.colorScheme.primary,
                                    labelStyle: TextStyle(color: selectedSection == null ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedSection = null;
                                        });
                                        applyFilters();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ...sections.map(
                                    (section) => _buildAnimatedChoiceChip(section, selectedSection == section, (selected) {
                                      setState(() {
                                        selectedSection = selected ? section : null;
                                      });
                                      applyFilters();
                                    }, theme),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Level filter
                            Text('Level:', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('All'),
                                    selected: selectedLevel == null,
                                    selectedColor: theme.colorScheme.primary,
                                    labelStyle: TextStyle(color: selectedLevel == null ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedLevel = null;
                                        });
                                        applyFilters();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ...levels.map(
                                    (level) => _buildAnimatedChoiceChip(level, selectedLevel == level, (selected) {
                                      setState(() {
                                        selectedLevel = selected ? level : null;
                                      });
                                      applyFilters();
                                    }, theme),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Type filter
                            Text('Type:', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('All'),
                                    selected: selectedType == null,
                                    selectedColor: theme.colorScheme.primary,
                                    labelStyle: TextStyle(color: selectedType == null ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedType = null;
                                        });
                                        applyFilters();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ...types.map(
                                    (type) => _buildAnimatedChoiceChip(type, selectedType == type.toLowerCase(), (selected) {
                                      setState(() {
                                        selectedType = selected ? type.toLowerCase() : null;
                                      });
                                      applyFilters();
                                    }, theme),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Action buttons with animated appearance
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Clear filters button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      selectedSection = null;
                                      selectedLevel = null;
                                      selectedType = null;
                                    });
                                    applyFilters();

                                    // Auto close after clearing filters
                                    _toggleExpanded();
                                  },
                                  icon: Icon(MdiIcons.filterRemoveOutline),
                                  label: const Text('Clear All'),
                                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
                                ),

                                // Done button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _toggleExpanded();
                                  },
                                  icon: Icon(MdiIcons.check),
                                  label: const Text('Apply'),
                                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create animated choice chips
  Widget _buildAnimatedChoiceChip(String label, bool isSelected, Function(bool) onSelected, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          selectedColor: theme.colorScheme.primary,
          labelStyle: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          onSelected: onSelected,
          // Add a subtle scale animation when selected
          avatar: isSelected ? Icon(MdiIcons.check, size: 16, color: theme.colorScheme.onPrimary) : null,
        ),
      ),
    );
  }

  // Helper method to create animated filter summary chips
  Widget _buildAnimatedChip(String label, VoidCallback onDelete, Color backgroundColor, Color textColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Chip(
            label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            onDeleted: onDelete,
            deleteIcon: Icon(MdiIcons.close, size: 16, color: textColor),
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}
