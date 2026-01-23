(function () {
    const banner = document.getElementById("cookie-consent-banner");
    const acceptBtn = document.getElementById("accept-cookies");
    const declineBtn = document.getElementById("decline-cookies");
    let lastFocusedElement = null;

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

    function openBanner() {
        if (!banner) {
            return;
        }
        lastFocusedElement = document.activeElement;
        banner.classList.remove("hidden");
        if (!banner.open) {
            banner.showModal();
        }
        const firstAction = acceptBtn || declineBtn;
        firstAction?.focus();
    }

    function closeBanner() {
        if (!banner) {
            return;
        }
        if (banner.open) {
            banner.close();
        }
        banner.classList.add("hidden");
    }

    if (!consent) {
        openBanner();
    } else if (consent === "accepted") {
        loadAnalytics();
    }

    acceptBtn?.addEventListener("click", () => {
        localStorage.setItem("cookieConsent", "accepted");
        closeBanner();
        loadAnalytics();
    });

    declineBtn?.addEventListener("click", () => {
        localStorage.setItem("cookieConsent", "declined");
        closeBanner();
    });

    banner?.addEventListener("close", () => {
        banner.classList.add("hidden");
        lastFocusedElement?.focus();
    });
})();
