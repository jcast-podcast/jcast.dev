(function () {
    var select = document.getElementById('topic-select');
    if (!select) return;

    select.addEventListener('change', function () {
        if (select.value) window.location.href = select.value;
    });
})();
