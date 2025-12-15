document.addEventListener('DOMContentLoaded', () => {
    document
        .querySelectorAll('link[data-fa-preload]')
        .forEach(link => {
            link.addEventListener('load', () => {
                link.rel = 'stylesheet';
            });
        });
});
