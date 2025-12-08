# 📚 Panduan Penggunaan Optimisasi MyStudyMate

## Cara Menggunakan Performance Helper

### 1. Measure Async Operations

```dart
import '../utils/performance_helper.dart';

// Di service atau method
Future<List<Schedule>> getSchedules() async {
  return await PerformanceHelper.measureAsync(
    'Fetch Schedules',
    () => _dio.get('/schedules'),
  );
}

// Output: ⏱️ Fetch Schedules took 234ms
```

### 2. Measure Sync Operations

```dart
// Di build method atau computation
final result = PerformanceHelper.measure(
  'Calculate Total',
  () {
    return items.fold(0, (sum, item) => sum + item.value);
  },
);
```

### 3. Track Widget Rebuilds

```dart
class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    PerformanceHelper().trackBuild('MyWidget');
    return Container(...);
  }
}

// Di akhir session, print statistics:
PerformanceHelper().printBuildStats();
```

### 4. Debouncing untuk Search

```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}
```

### 5. Throttling untuk Button Clicks

```dart
final _throttler = Throttler(duration: Duration(seconds: 2));

void _onButtonPressed() {
  _throttler.throttle(() {
    // This will only execute once every 2 seconds
    _submitForm();
  });
}

@override
void dispose() {
  _throttler.dispose();
  super.dispose();
}
```

### 6. Lazy Value Initialization

```dart
class MyService {
  // Expensive initialization only when needed
  final _expensiveData = LazyValue<Map<String, dynamic>>(() {
    return computeExpensiveData();
  });

  Map<String, dynamic> get data => _expensiveData.value;
}
```

### 7. Memory Cache Usage

```dart
// Create cache with max 50 items
final _imageCache = MemoryCache<String, ImageProvider>(maxSize: 50);

ImageProvider getImage(String url) {
  var cached = _imageCache.get(url);
  if (cached != null) return cached;
  
  final image = NetworkImage(url);
  _imageCache.put(url, image);
  return image;
}
```

---

## Cara Menggunakan Optimized Widgets

### 1. OptimizedListTile

```dart
import '../widgets/optimized_widgets.dart';

ListView.builder(
  itemBuilder: (context, index) {
    return OptimizedListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text('Item $index'),
      subtitle: Text('Description'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => print('Tapped $index'),
    );
  },
)
```

### 2. OptimizedCard

```dart
OptimizedCard(
  elevation: 4,
  borderRadius: BorderRadius.circular(16),
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.all(10),
  onTap: () => print('Card tapped'),
  child: Column(
    children: [
      Text('Card Title'),
      SizedBox(height: 8),
      Text('Card Content'),
    ],
  ),
)
```

### 3. CachedBuilder

```dart
// Widget yang expensive untuk di-build
CachedBuilder(
  shouldRebuild: false, // Hanya rebuild saat set true
  builder: (context) {
    return ComplexWidget(
      // Expensive computation
      data: _computeExpensiveData(),
    );
  },
)
```

### 4. OptimizedImage

```dart
OptimizedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
)
```

### 5. LazyListView dengan Pagination

```dart
LazyListView<Schedule>(
  items: _schedules,
  itemBuilder: (context, schedule, index) {
    return ScheduleCard(schedule: schedule);
  },
  onLoadMore: () async {
    // Load more items
    final nextPage = await _service.getNextPage();
    return nextPage;
  },
  physics: BouncingScrollPhysics(),
  padding: EdgeInsets.all(16),
)
```

### 6. ShimmerLoading

```dart
// Saat loading data
_isLoading
  ? Column(
      children: [
        ShimmerLoading(width: 200, height: 20),
        SizedBox(height: 8),
        ShimmerLoading(width: 150, height: 16),
      ],
    )
  : ActualContent()
```

---

## Best Practices Implementation

### ✅ Screen dengan AutomaticKeepAliveClientMixin

```dart
class _MyScreenState extends State<MyScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // REQUIRED!
    return Scaffold(...);
  }
}
```

### ✅ Prevent Concurrent API Calls

```dart
bool _isLoading = false;

Future<void> _loadData() async {
  if (!mounted) return;
  if (_isLoading) return; // ⚡ Key optimization
  
  setState(() => _isLoading = true);
  try {
    final data = await _service.getData();
    if (mounted) {
      setState(() {
        _data = data;
      });
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### ✅ Cache User Data

```dart
class _HomeScreenState extends State<HomeScreen> {
  String? _cachedUserName;
  String? _cachedProfileUrl;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _cachedUserName = user.name;
        _cachedProfileUrl = user.profilePhotoUrl;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Use cached values, no FutureBuilder!
    return Text(_cachedUserName ?? 'Guest');
  }
}
```

### ✅ Optimized Images

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 200,      // Resize in memory
  memCacheHeight: 200,
  maxWidthDiskCache: 200,  // Resize in disk cache
  maxHeightDiskCache: 200,
  fit: BoxFit.cover,
  placeholder: (context, url) => ShimmerLoading(
    width: 200,
    height: 200,
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### ✅ RepaintBoundary untuk Isolasi

```dart
Widget _buildComplexSection() {
  return RepaintBoundary(
    child: Column(
      children: [
        // Complex widgets that don't need to rebuild
        // when parent rebuilds
      ],
    ),
  );
}
```

### ✅ Const Constructors

```dart
// Use const whenever possible
const SizedBox(height: 16)
const Icon(Icons.home)
const Text('Static Text')
const EdgeInsets.all(16)

// Not const (values are dynamic)
SizedBox(height: dynamicHeight)
Icon(Icons.home, color: dynamicColor)
Text(userName)
EdgeInsets.all(dynamicPadding)
```

---

## Testing Performance

### 1. Enable Performance Overlay

```dart
// In main.dart temporarily
MaterialApp(
  showPerformanceOverlay: true, // Shows FPS
  ...
)
```

### 2. Run in Profile Mode

```bash
# Build and run in profile mode
flutter run --profile

# Check performance metrics
flutter attach
# Then open DevTools
```

### 3. Memory Profiling

```bash
# Run with observatory
flutter run --profile --enable-observatory

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 4. Build Time Analysis

```bash
# Analyze build performance
flutter build apk --analyze-size

# Create release build
flutter build apk --release
```

---

## Common Performance Issues & Solutions

### Issue 1: Screen Lag saat Scroll

**Masalah:** List terasa lag saat di-scroll

**Solusi:**
```dart
// Use ListView.builder, NOT ListView with children
ListView.builder(
  physics: BouncingScrollPhysics(),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return RepaintBoundary(  // Isolate each item
      child: ItemWidget(items[index]),
    );
  },
)
```

### Issue 2: Slow Screen Transitions

**Masalah:** Navigation terasa lambat

**Solusi:**
```dart
// Use lazy routes
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextScreen(), // Built on demand
  ),
);

// NOT preloading all routes in MaterialApp
```

### Issue 3: High Memory Usage

**Masalah:** App menggunakan terlalu banyak memory

**Solusi:**
```dart
// 1. Optimize images
CachedNetworkImage(
  memCacheWidth: 100,  // ⚡ Key!
  memCacheHeight: 100,
)

// 2. Clear cache periodically
@override
void dispose() {
  _cache.clear();
  _controller.dispose();
  super.dispose();
}

// 3. Use pagination
LazyListView(
  onLoadMore: () => loadNextPage(),
)
```

### Issue 4: Widget Rebuilding Too Often

**Masalah:** setState() dipanggil terlalu sering

**Solusi:**
```dart
// 1. Track rebuilds
PerformanceHelper().trackBuild('MyWidget');

// 2. Use RepaintBoundary
RepaintBoundary(child: MyWidget())

// 3. Split into smaller widgets
class _MySmallWidget extends StatelessWidget {
  const _MySmallWidget(); // const constructor
  // Only this rebuilds, not parent
}
```

### Issue 5: Slow API Calls

**Masalah:** API response lambat

**Solusi:**
```dart
// 1. Reduce timeouts
_dio.options.connectTimeout = Duration(seconds: 10);
_dio.options.receiveTimeout = Duration(seconds: 15);

// 2. Cache responses
final _cache = MemoryCache<String, dynamic>(maxSize: 50);

Future<dynamic> fetchData(String endpoint) async {
  final cached = _cache.get(endpoint);
  if (cached != null) return cached;
  
  final response = await _dio.get(endpoint);
  _cache.put(endpoint, response.data);
  return response.data;
}

// 3. Use pagination
final response = await _dio.get('/items?page=$page&limit=20');
```

---

## Monitoring Checklist

✅ **Setelah setiap build, check:**
- [ ] FPS stays above 55-60
- [ ] Memory usage < 200MB for normal usage
- [ ] Screen transitions < 300ms
- [ ] API calls complete < 2s
- [ ] No yellow overflow warnings
- [ ] No red error boxes

✅ **Before releasing, ensure:**
- [ ] All debug prints removed
- [ ] showPerformanceOverlay = false
- [ ] debugShowCheckedModeBanner = false
- [ ] Run flutter analyze with no errors
- [ ] Build release APK and test on real device
- [ ] Memory profiling shows no leaks
- [ ] Lighthouse/Performance tests pass

---

## Resources

- [Flutter Performance Docs](https://docs.flutter.dev/perf)
- [DevTools Guide](https://docs.flutter.dev/tools/devtools)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)

---

**Happy Optimizing! 🚀**
