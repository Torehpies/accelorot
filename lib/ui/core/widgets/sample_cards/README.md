# Filterable Card List Container

A reusable Flutter container widget for displaying filterable and searchable lists of cards.

## Features

- 🔍 **Search functionality** - Filter cards with a search bar
- 🏷️ **Filter chips** - Horizontal scrollable filter tabs
- 📱 **Responsive cards** - Display any widget as cards
- 🎨 **Customizable** - Custom colors, padding, and styling
- ⚡ **Loading states** - Built-in loading indicator
- 📭 **Empty states** - Default empty state with custom option

## Usage

### Basic Example

```dart
FilterableCardListContainer(
  filters: ['All', 'Active', 'Inactive'],
  selectedFilter: _selectedFilter,
  onFilterChanged: (filter) {
    setState(() {
      _selectedFilter = filter;
    });
  },
  cards: yourCardWidgets,
)
```

### With Search

```dart
FilterableCardListContainer(
  filters: ['All', 'Greens', 'Browns', 'Compost'],
  selectedFilter: _selectedFilter,
  onFilterChanged: (filter) {
    setState(() => _selectedFilter = filter);
  },
  searchQuery: _searchQuery,
  onSearchChanged: (query) {
    setState(() => _searchQuery = query);
  },
  cards: yourCardWidgets,
  searchHint: 'Search items...',
)
```

### With Custom Filter Colors

```dart
FilterableCardListContainer(
  filters: ['All', 'Active', 'Inactive', 'Archived'],
  selectedFilter: _selectedFilter,
  onFilterChanged: (filter) {
    setState(() => _selectedFilter = filter);
  },
  cards: yourCardWidgets,
  filterColors: {
    'All': Color(0xFF6B7280),
    'Active': Color(0xFF4CAF50),
    'Inactive': Color(0xFFFFA726),
    'Archived': Color(0xFFEF5350),
  },
)
```

### With Custom Empty State

```dart
FilterableCardListContainer(
  filters: ['All', 'Active'],
  selectedFilter: _selectedFilter,
  onFilterChanged: (filter) {
    setState(() => _selectedFilter = filter);
  },
  cards: yourCardWidgets,
  emptyState: Center(
    child: Text('No items available'),
  ),
)
```

## Sample Cards

The package includes two sample card widgets:

### 1. CompostCard

A card for displaying compost/waste items with:
- Icon with colored background
- Title and weight
- Machine and batch information
- User and timestamp

```dart
CompostCard(
  title: 'Compost',
  icon: Icons.recycling,
  iconColor: Color(0xFF6B7280),
  machineName: 'MACHINE_101',
  batchName: 'BATCH_1',
  userName: 'John Doe',
  dateTime: '10-25-2025, 2:30 PM',
  weight: '20.0kg',
  onTap: () {
    // Handle tap
  },
)
```

### 2. MachineStatusCard

A card for displaying machine status with:
- Machine icon
- Machine name and ID
- Assigned user
- Date created
- Status badge with color

```dart
MachineStatusCard(
  machineName: 'MACHINE_101',
  machineId: '01',
  assignedUser: 'All Team Members',
  dateCreated: 'Oct-5-2025',
  status: 'Active',
  statusColor: Color(0xFF4CAF50),
  onTap: () {
    // Handle tap
  },
)
```

## Complete Examples

See [example_usage.dart](./example_usage.dart) for complete working examples:
- `CompostListExample` - List of compost items with filtering
- `MachineListExample` - List of machines with status filtering

## Parameters

### FilterableCardListContainer

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filters` | `List<String>` | Yes | List of filter options |
| `selectedFilter` | `String` | Yes | Currently selected filter |
| `onFilterChanged` | `ValueChanged<String>` | Yes | Callback when filter changes |
| `cards` | `List<Widget>` | Yes | List of card widgets to display |
| `searchQuery` | `String?` | No | Current search query |
| `onSearchChanged` | `ValueChanged<String>?` | No | Callback when search changes |
| `showSearch` | `bool` | No | Show/hide search bar (default: true) |
| `showFilters` | `bool` | No | Show/hide filter chips (default: true) |
| `searchHint` | `String` | No | Placeholder for search field |
| `emptyState` | `Widget?` | No | Custom empty state widget |
| `isLoading` | `bool` | No | Show loading indicator |
| `backgroundColor` | `Color?` | No | Container background color |
| `padding` | `EdgeInsetsGeometry?` | No | Container padding |
| `filterColors` | `Map<String, Color>?` | No | Custom colors per filter |

## Customization Tips

1. **Filter your data** in the parent widget's state before passing cards
2. **Implement search** by filtering cards based on searchQuery
3. **Custom cards** can be any widget - not limited to the sample cards
4. **Colors** can be customized per filter for visual distinction
5. **Empty state** can show helpful messages or actions

## Design Patterns

This widget follows Flutter best practices:
- ✅ Stateful widget for internal state management
- ✅ Callbacks for parent state updates
- ✅ Flexible composition with widget list
- ✅ Responsive layout with ListView
- ✅ Material Design 3 styling
- ✅ Accessibility support
