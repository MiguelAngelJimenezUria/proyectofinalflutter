class User {
	final String id;
	final String? email;
	final String username;
	final String? gender;
	final String? avatarUrl;
	final DateTime createdAt;

	User({
		required this.id,
		this.email,
		this.username = '',
		this.gender,
		this.avatarUrl,
		DateTime? createdAt,
	}) : createdAt = createdAt ?? DateTime.now();

	User copyWith({
		String? id,
		String? email,
		String? username,
		String? gender,
		String? avatarUrl,
		DateTime? createdAt,
	}) {
		return User(
			id: id ?? this.id,
			email: email ?? this.email,
			username: username ?? this.username,
			gender: gender ?? this.gender,
			avatarUrl: avatarUrl ?? this.avatarUrl,
			createdAt: createdAt ?? this.createdAt,
		);
	}

	Map<String, dynamic> toJson() => {
				'id': id,
				'email': email,
				'username': username,
				'gender': gender,
				'avatarUrl': avatarUrl,
				'createdAt': createdAt.toIso8601String(),
			};

	/// Crea un User a partir de un Map. Acepta tanto snake_case (como viene de
	/// Supabase) como camelCase (como se usa en el código Dart).
	factory User.fromJson(Map<String, dynamic> json) {
		// Helper para obtener valor con dos posibles keys
		T? _get<T>(Map<String, dynamic> m, String camel, String snake) {
			if (m.containsKey(camel) && m[camel] != null) return m[camel] as T;
			if (m.containsKey(snake) && m[snake] != null) return m[snake] as T;
			return null;
		}

		final id = _get<String>(json, 'id', 'id') ?? '';
		final email = _get<String>(json, 'email', 'email');
		final username = _get<String>(json, 'username', 'username') ?? '';
		final gender = _get<String>(json, 'gender', 'gender');
		final avatarUrl = _get<String>(json, 'avatarUrl', 'avatar_url');

		final createdAtStr = _get<String>(json, 'createdAt', 'created_at');
		DateTime createdAt;
		if (createdAtStr != null) {
			try {
				createdAt = DateTime.parse(createdAtStr);
			} catch (_) {
				createdAt = DateTime.now();
			}
		} else if (json.containsKey('created_at') && json['created_at'] is DateTime) {
			createdAt = json['created_at'] as DateTime;
		} else {
			createdAt = DateTime.now();
		}

		return User(
			id: id,
			email: email,
			username: username,
			gender: gender,
			avatarUrl: avatarUrl,
			createdAt: createdAt,
		);
	}

	@override
	String toString() => 'User(id: $id, username: $username, email: $email)';
}

