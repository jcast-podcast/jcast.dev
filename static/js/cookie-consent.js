(function () {
    const banner = document.getElementById("cookie-consent-banner");
    const acceptBtn = document.getElementById("accept-cookies");
    const declineBtn = document.getElementById("decline-cookies");

    const consent = localStorage.getItem("cookieConsent");

    function loadAnalytics() {
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}

        const gtagScript = document.createElement('script');
        gtagScript.setAttribute('async', '');
        gtagScript.src = 'https://www.googletagmanager.com/gtag/js?id=G-XW26YSCBZG';

        gtagScript.onload = function() {
            gtag('js', new Date());
            gtag('config', 'G-XW26YSCBZG');
        };

        document.head.appendChild(gtagScript);
    }

    if (!consent) {
        banner.classList.remove("hidden");
    } else if (consent === "accepted") {
        loadAnalytics();
    }

    acceptBtn?.addEventListener("click", () => {
        localStorage.setItem("cookieConsent", "accepted");
        banner.classList.add("hidden");
        loadAnalytics();
    });

    declineBtn?.addEventListener("click", () => {
        localStorage.setItem("cookieConsent", "declined");
        banner.classList.add("hidden");
    });
})();
