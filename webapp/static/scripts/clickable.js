$(document).ready(function() {
    $('.clickable-tr').on('click', function() {
        window.location.href=$(this).attr('data-href');
    });
});
