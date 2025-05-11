import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:flutter/material.dart';

class SpaceListManagement extends StatefulWidget {
  final List<ParkingSpace> spaces;
  final Function(ParkingSpace) onEditSpace;
  final Function(ParkingSpace) onDeleteSpace;
  final bool isLoading;
  // Add custom loading builder parameter
  final Widget Function()? loadingBuilder;

  const SpaceListManagement({super.key, required this.spaces, required this.onEditSpace, required this.onDeleteSpace, this.isLoading = false, this.loadingBuilder});

  @override
  State<SpaceListManagement> createState() => _SpaceListManagementState();
}

class _SpaceListManagementState extends State<SpaceListManagement> {
  String? filterSection;
  String? filterLevel;
  String? filterType;
  String? filterStatus;
  String searchQuery = '';

  List<ParkingSpace> get filteredSpaces {
    return widget.spaces.where((space) {
      // Apply search query
      if (searchQuery.isNotEmpty && !space.spaceNumber.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      // Apply section filter
      if (filterSection != null && space.section != filterSection) {
        return false;
      }

      // Apply level filter
      if (filterLevel != null && space.level != filterLevel) {
        return false;
      }

      // Apply type filter
      if (filterType != null && space.type.toLowerCase() != filterType!.toLowerCase()) {
        return false;
      }

      // Apply status filter
      if (filterStatus != null && space.status.toLowerCase() != filterStatus!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add more padding around the search field
        Padding(padding: const EdgeInsets.only(bottom: 16.0), child: _buildSearchField()),
        // Increase space between filter chips
        _buildFilterChips(),
        // Increase space before the list
        const SizedBox(height: 24),
        Expanded(
          child:
              widget.isLoading
                  ? widget.loadingBuilder != null
                      ? widget.loadingBuilder!() // Use custom loading builder if provided
                      : const Center(child: CircularProgressIndicator()) // Fallback to default
                  : filteredSpaces.isEmpty
                  ? _buildEmptyState()
                  : _buildSpacesList(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by space number',
        prefixIcon: Container(width: 48, height: 48, alignment: Alignment.center, child: const Text('🔍', style: TextStyle(fontSize: 20))),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            // Section filter - using standard Flutter icons with explicit colors
            _buildFilterDropdown(
              label: 'Section',
              icon: Icons.place,
              value: filterSection,
              items: ['A', 'B', 'C', 'D'],
              onChanged: (value) {
                setState(() {
                  filterSection = value;
                });
              },
            ),

            const SizedBox(width: 12), // Increase spacing
            // Level filter
            _buildFilterDropdown(
              label: 'Level',
              icon: Icons.layers,
              value: filterLevel,
              items: ['G', '1', '2', '3'],
              onChanged: (value) {
                setState(() {
                  filterLevel = value;
                });
              },
            ),

            const SizedBox(width: 12), // Increase spacing
            // Type filter
            _buildFilterDropdown(
              label: 'Type',
              icon: Icons.directions_car,
              value: filterType,
              items: ['Regular', 'Compact', 'Handicapped', 'Electric'],
              onChanged: (value) {
                setState(() {
                  filterType = value?.toLowerCase();
                });
              },
            ),

            const SizedBox(width: 12), // Increase spacing
            // Status filter
            _buildFilterDropdown(
              label: 'Status',
              icon: Icons.info_outline,
              value: filterStatus,
              items: ['Vacant', 'Occupied'],
              onChanged: (value) {
                setState(() {
                  filterStatus = value?.toLowerCase();
                });
              },
            ),

            const SizedBox(width: 12), // Increase spacing
            // Clear filters
            if (filterSection != null || filterLevel != null || filterType != null || filterStatus != null || searchQuery.isNotEmpty)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    filterSection = null;
                    filterLevel = null;
                    filterType = null;
                    filterStatus = null;
                    searchQuery = '';
                  });
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Container for proper emoji alignment
                    Container(width: 24, alignment: Alignment.center, child: Text('🧹', style: TextStyle(fontSize: 16))),
                    const SizedBox(width: 8), // Increased spacing
                    const Text('Clear'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Changed to use emojis instead of MaterialIcons with better spacing
  Widget _buildFilterDropdown({required String label, required IconData icon, required String? value, required List<String> items, required Function(String?) onChanged}) {
    // Convert icons to emojis
    String getEmoji() {
      if (icon == Icons.place) return '📍';
      if (icon == Icons.layers) return '🔢';
      if (icon == Icons.directions_car) return '🚗';
      if (icon == Icons.info_outline) return 'ℹ️';
      return '•';
    }

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container to properly center and position emoji
                Container(width: 24, alignment: Alignment.center, child: Text(getEmoji(), style: const TextStyle(fontSize: 16))),
                const SizedBox(width: 6), // Reduced spacing
                Text(label),
              ],
            ),
          ),
          // Add padding around dropdown button
          itemHeight: 48,
          icon: Padding(padding: const EdgeInsets.only(left: 8), child: const Text('▼', style: TextStyle(fontSize: 12))),
          isDense: true,
          items: [
            DropdownMenuItem<String>(value: null, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('All $label'))),
            ...items.map((item) => DropdownMenuItem<String>(value: item, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(item)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    bool hasFilters = filterSection != null || filterLevel != null || filterType != null || filterStatus != null || searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hasFilters ? '🚫' : 'P', style: TextStyle(fontSize: 64, color: Colors.grey[400], fontWeight: hasFilters ? FontWeight.normal : FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No spaces match your filters' : 'No parking spaces available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters ? 'Try adjusting or clearing your filters' : 'Create your first parking space to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  filterSection = null;
                  filterLevel = null;
                  filterType = null;
                  filterStatus = null;
                  searchQuery = '';
                });
              },
              style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.primary)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container for proper emoji alignment
                  Container(width: 24, alignment: Alignment.center, child: Text('🧹', style: TextStyle(fontSize: 16))),
                  const SizedBox(width: 10), // Increased spacing
                  Text('Clear All Filters', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpacesList() {
    return ListView.builder(
      itemCount: filteredSpaces.length,
      itemBuilder: (context, index) {
        final space = filteredSpaces[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              radius: 24, // Explicitly set size
              child: Center(child: Text(_getTypeEmoji(space.type), style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSecondaryContainer))),
            ),
            title: Text('Space ${space.spaceNumber}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Section ${space.section}, Level ${space.level ?? 'G'}'),
                const SizedBox(height: 4),
                // Wrap in a FittedBox to prevent overflow
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Use min to prevent overflow
                    children: [
                      Container(width: 20, alignment: Alignment.center, child: Text('💲', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary))),
                      Text('${space.hourlyRate.toStringAsFixed(2)}/hr', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: space.status.toLowerCase() == 'vacant' ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          space.status.toLowerCase() == 'vacant' ? 'Available' : 'Occupied',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Make buttons smaller and more compact
            trailing: SizedBox(
              width: 80, // Constrain width to prevent overflow
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: TextButton(
                      onPressed: () => widget.onEditSpace(space),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: Center(child: Text('✏️', style: TextStyle(fontSize: 18))),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: TextButton(
                      onPressed: () => widget.onDeleteSpace(space),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: Center(child: Text('🗑️', style: TextStyle(fontSize: 18))),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => widget.onEditSpace(space),
          ),
        );
      },
    );
  }

  // Using emojis instead of Material icons
  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'handicapped':
        return '♿';
      case 'compact':
        return '🚗';
      case 'electric':
        return '🔌';
      default:
        return 'P';
    }
  }
}
