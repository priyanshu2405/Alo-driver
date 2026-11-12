/*
mixin class PaginationController<T>  {
  final RxList<T> items = <T>[].obs;

  var page = 1;
  final int  limit = 10;
  var isLoading = false.obs;
  var hasMore = true.obs;

//  final Future<List<T>> Function(int page, int limit) fetchPage;

*//*  PaginationController({
    required this.fetchPage,
    this.limit = 10,
  });*/
/*

  Future<void> loadInitial() async {
    page = 1;
    items.clear();
    hasMore.value = true;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    final result = await fetchPage(page, limit);
    if (result.isEmpty) {
      hasMore.value = false;
    } else {
      items.addAll(result);
      page++;
    }
    isLoading.value = false;
  }
}*/

mixin PaginationController<T> {
  int page = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool isFirstLoad = true;
  int pagination = 10;

  void resetPagination() {
    page = 1;
    hasMore = true;
    isLoading = false;
    isFirstLoad = true;
  }

  void nextPage() {
    page++;
  }
}