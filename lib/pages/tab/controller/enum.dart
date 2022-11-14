/// 数据加载状态
enum PageState {
  None, // 现在什么也没做(网络请求前,网络请求完成)
  Loading, // 加载中
  LoadingMore, // 加载更多
  LoadingPrev, // 加载上一页
  LoadingError, // 加载失败(业务逻辑错误)
  LoadingException, // 网络异常
}
