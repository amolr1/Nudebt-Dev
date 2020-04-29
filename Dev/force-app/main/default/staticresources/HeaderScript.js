window.onload = function() {
    var reloading = window.sessionStorage.getItem("reloading");
    if (reloading) {
        sessionStorage.removeItem("reloading");
    }
}