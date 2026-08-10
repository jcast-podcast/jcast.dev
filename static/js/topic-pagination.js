(function () {
    var nav = document.getElementById('content-pagination');
    if (!nav) return;

    var pageSize = 3;
    var sections = [
        { section: document.getElementById('episodes-section'), grid: document.getElementById('episodes-grid') },
        { section: document.getElementById('posts-section'), grid: document.getElementById('posts-grid') }
    ].filter(function (s) { return s.section && s.grid; });

    sections.forEach(function (s) {
        s.cards = Array.prototype.slice.call(s.grid.children);
    });

    var flatCards = [];
    sections.forEach(function (s) {
        s.cards.forEach(function (card) {
            flatCards.push(card);
        });
    });

    var totalPages = Math.max(1, Math.ceil(flatCards.length / pageSize));
    var current = 0;
    var prevBtn = nav.querySelector('[data-action="prev"]');
    var nextBtn = nav.querySelector('[data-action="next"]');
    var currentEl = nav.querySelector('[data-current]');

    function render() {
        flatCards.forEach(function (card, i) {
            card.style.display = Math.floor(i / pageSize) === current ? '' : 'none';
        });
        sections.forEach(function (s) {
            var anyVisible = s.cards.some(function (card) {
                return card.style.display !== 'none';
            });
            s.section.style.display = anyVisible ? '' : 'none';
        });
        currentEl.textContent = current + 1;
        prevBtn.classList.toggle('pagination-btn--disabled', current === 0);
        nextBtn.classList.toggle('pagination-btn--disabled', current === totalPages - 1);
    }

    prevBtn.addEventListener('click', function () {
        if (current === 0) return;
        current -= 1;
        render();
        nav.scrollIntoView({ behavior: 'smooth', block: 'center' });
    });
    nextBtn.addEventListener('click', function () {
        if (current === totalPages - 1) return;
        current += 1;
        render();
        nav.scrollIntoView({ behavior: 'smooth', block: 'center' });
    });

    render();
})();
