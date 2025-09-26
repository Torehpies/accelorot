class AppUser {
	final String id;
	final String fullName;
	final String email;
	final String? photoUrl;
	
	AppUser({
		required this.id,
		required this.fullName,
		required this.email,
		this.photoUrl,
	});

	factory AppUser.fromFirestore(Map<String, dynamic> data) {
		return AppUser(
			id: data["uid"],
			fullName: data["fullName"],
			email: data["email"],
			photoUrl: data["photoUrl"],
		);
	}

	Map<String, dynamic> toFirestore() {
		return {
			"uid": id,
			"fullName": fullName,
			"email": email,
			"photoUrl": photoUrl,
		};
	}
}
