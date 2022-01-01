user_info(resp => {
	let provider = document.getElementById("provider");
	let username = document.getElementById("username");
	let avatar = document.getElementById("avatar");

	provider.src = "/account/" + resp.provider + ".ico";
	username.innerText = resp.name;
	avatar.src = resp.avatar;
});
