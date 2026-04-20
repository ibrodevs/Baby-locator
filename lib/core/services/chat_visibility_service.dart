class ChatVisibilityService {
  ChatVisibilityService._();

  static final ChatVisibilityService instance = ChatVisibilityService._();

  final Map<Object, int> _activeChats = <Object, int>{};

  int? get activeChildId =>
      _activeChats.isEmpty ? null : _activeChats.values.last;

  bool isChatOpenFor(int childId) => _activeChats.containsValue(childId);

  void setActiveChildFor(Object owner, int? childId) {
    if (childId == null) {
      _activeChats.remove(owner);
      return;
    }
    _activeChats[owner] = childId;
  }

  void clear(Object owner) {
    _activeChats.remove(owner);
  }
}
