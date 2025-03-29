let debug = false;
let timers = {};
let timeoutIds = {}; // New object to track timeout IDs

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'setDebug') {
        debug = data.debug;
    } else if (data.action === 'setPosition') {
        setTimerPosition(data.position);
    } else if (data.action === 'startTimer') {
        if (debug) {
            console.log('Setting timer position to:', data.position);
        }
        setTimerPosition(data.position);
        startTimer(data.index, data.duration);
    } else if (data.action === 'stopTimer') {
        stopTimer(data.index);
    }
    if (debug) {
        console.log('Received message:', data);
    }
});

function setTimerPosition(position) {
    const container = document.getElementById('timer-container');
    if (!container) {
        if (debug) {
            console.error('Timer container not found!');
        }
        return;
    }
    if (debug) {
        console.log('Applying position:', position);
    }
    container.style.top = '';
    container.style.bottom = '';
    container.style.left = '';
    container.style.right = '';
    container.style.transform = '';

    switch (position) {
        case 'bottom-left':
            container.style.bottom = '10px';
            container.style.left = '10px';
            break;
        case 'bottom':
            container.style.bottom = '10px';
            container.style.left = '50%';
            container.style.transform = 'translateX(-50%)';
            break;
        case 'bottom-right':
            container.style.bottom = '10px';
            container.style.right = '10px';
            break;
        case 'right':
            container.style.top = '50%';
            container.style.right = '10px';
            container.style.transform = 'translateY(-50%)';
            break;
        case 'top-right':
            container.style.top = '10px';
            container.style.right = '10px';
            break;
        case 'top':
            container.style.top = '10px';
            container.style.left = '50%';
            container.style.transform = 'translateX(-50%)';
            break;
        case 'top-left':
            container.style.top = '10px';
            container.style.left = '10px';
            break;
        case 'left':
            container.style.top = '50%';
            container.style.left = '10px';
            container.style.transform = 'translateY(-50%)';
            break;
        default:
            if (debug) {
                console.warn('Unknown position:', position, 'defaulting to bottom-right');
            }
            container.style.bottom = '10px';
            container.style.right = '10px';
    }
    if (debug) {
        console.log('Applied styles:', container.style.cssText);
    }
}

function startTimer(index, duration) {
    // Cancel any pending timeout for this sphere
    if (timeoutIds[index]) {
        clearTimeout(timeoutIds[index]);
        delete timeoutIds[index];
    }
    timers[index] = {
        startTime: Date.now(),
        duration: duration * 1000
    };
    updateTimer(index);
    document.getElementById('timer-container').classList.remove('hidden');
}

function stopTimer(index) {
    if (timers[index]) {
        delete timers[index];
        if (Object.keys(timers).length === 0) {
            document.getElementById('timer-container').classList.add('hidden');
        }
    }
}

function updateTimer(index) {
    const timer = timers[index];
    if (timer) {
        const elapsed = Date.now() - timer.startTime;
        const remaining = Math.max(0, timer.duration - elapsed);
        if (remaining > 0) {
            const seconds = Math.ceil(remaining / 1000);
            document.getElementById('timer-text').innerHTML = `Combat Timer: <span id="time">${seconds}</span>s`;
            requestAnimationFrame(() => updateTimer(index));
        } else {
            document.getElementById('timer-text').innerHTML = "Combat Timer Expired";
            timeoutIds[index] = setTimeout(() => stopTimer(index), 5000); // Store timeout ID
        }
    }
}