user_info(resp => {
	let provider = document.getElementById("provider");
	let username = document.getElementById("username");
	let avatar = document.getElementById("avatar");

	provider.innerText = "OAuth Provider: " + resp.provider;
	username.innerText = resp.name;
	avatar.src = resp.avatar;
});
