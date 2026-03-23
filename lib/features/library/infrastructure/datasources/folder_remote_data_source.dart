import '../../../../core/network/api_client.dart';

class FolderItem {
  final String id;
  final String name;

  const FolderItem({required this.id, required this.name});

  factory FolderItem.fromJson(Map<String, dynamic> json) {
    return FolderItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class FolderRemoteDataSource {
  final ApiClient api;

  FolderRemoteDataSource(this.api);

  /// GET /folders/root — list root folders for the active team.
  Future<List<FolderItem>> getRootFolders() async {
    final response = await api.get("/folders/root");
    final list = response.data is List ? response.data as List<dynamic> : [];
    return list.map((e) => FolderItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /folders/tree — get folder tree for the active team.
  Future<List<FolderTreeNode>> getFolderTree() async {
    final response = await api.get("/folders/tree");
    final list = response.data is List ? response.data as List<dynamic> : [];
    return list.map((e) => FolderTreeNode.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class FolderTreeNode {
  final String id;
  final String name;
  final List<FolderTreeNode> children;

  const FolderTreeNode({
    required this.id,
    required this.name,
    required this.children,
  });

  factory FolderTreeNode.fromJson(Map<String, dynamic> json) {
    final childrenList = json['children'] as List<dynamic>? ?? [];
    return FolderTreeNode(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      children: childrenList.map((e) => FolderTreeNode.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Flatten tree to a flat list (for dropdown).
  List<FolderItem> flatten() {
    List<FolderItem> out = [FolderItem(id: id, name: name)];
    for (var child in children) {
      out.addAll(child.flatten());
    }
    return out;
  }
}
