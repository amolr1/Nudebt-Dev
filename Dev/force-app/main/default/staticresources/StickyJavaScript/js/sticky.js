
alert('hi');
window.onscroll = function() {myFunction()};

var header = document.getElementById("navigation");
var sticky = header.offsetTop;

function myFunction() {
	alert('scroll');
  if (window.pageYOffset > sticky) {
    header.classList.add("sticky");
  } else {
    header.classList.remove("sticky");
  }
}