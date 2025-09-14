import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SearchType {
  normal,
  semantic,
}

class ModernSearchBar extends StatefulWidget {
  final String? initialQuery;
  final SearchType initialSearchType;
  final Function(String query, SearchType searchType)? onSearch;
  final Function()? onClear;
  final bool isExpanded;

  const ModernSearchBar({
    super.key,
    this.initialQuery,
    this.initialSearchType = SearchType.normal,
    this.onSearch,
    this.onClear,
    this.isExpanded = false,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late SearchType _searchType;
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _searchType = widget.initialSearchType;
    _isExpanded = widget.isExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _controller.clear();
      widget.onClear?.call();
    }
  }

  void _onSearch() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSearch?.call(_controller.text.trim(), _searchType);
    }
  }

  void _onSearchTypeChanged(SearchType type) {
    setState(() {
      _searchType = type;
    });
    _onSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main search row
          Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              
              // Search input
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: _searchType == SearchType.semantic 
                        ? 'Akıllı arama yapın...' 
                        : 'Arama yapın...',
                    border: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              
              // Search type toggle
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _animationController,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: _buildSearchTypeToggle(),
                    ),
                  );
                },
              ),
              
              // Expand/collapse button
              IconButton(
                onPressed: _toggleExpansion,
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          // Expanded options
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _animationController,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      
                      // Search type selection
                      Row(
                        children: [
                          Text(
                            'Arama Tipi:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                _buildSearchTypeChip(
                                  'Normal',
                                  SearchType.normal,
                                  Icons.search,
                                ),
                                const SizedBox(width: 8),
                                _buildSearchTypeChip(
                                  'Semantic',
                                  SearchType.semantic,
                                  Icons.psychology,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Search button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _onSearch,
                          icon: const Icon(Icons.search, size: 18),
                          label: Text(
                            _searchType == SearchType.semantic 
                                ? 'Akıllı Arama' 
                                : 'Ara',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildSearchTypeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _searchType == SearchType.semantic
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchType == SearchType.semantic ? Icons.psychology : Icons.search,
            size: 16,
            color: _searchType == SearchType.semantic
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            _searchType == SearchType.semantic ? 'AI' : 'Normal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _searchType == SearchType.semantic
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeChip(String label, SearchType type, IconData icon) {
    final isSelected = _searchType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSearchTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
