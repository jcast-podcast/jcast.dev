(function () {
    var button = document.getElementById('back-to-top');
    if (!button) return;

    var threshold = 400;

    function toggleVisibility() {
        if (window.scrollY > threshold) {
            button.classList.add('is-visible');
        } else {
            button.classList.remove('is-visible');
        }
    }

    button.addEventListener('click', function () {
        var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' });
    });

    window.addEventListener('scroll', toggleVisibility, { passive: true });
    toggleVisibility();
})();
