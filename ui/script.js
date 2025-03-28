let timers = {};

window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('Received message:', data);
    if (data.action === 'setPosition') {
        setTimerPosition(data.position);
    } else if (data.action === 'startTimer') {
        console.log('Setting timer position to:', data.position);
        setTimerPosition(data.position);
        startTimer(data.index, data.duration);
    } else if (data.action === 'stopTimer') {
        stopTimer(data.index);
    }
});

function setTimerPosition(position) {
    const container = document.getElementById('timer-container');
    if (!container) {
        console.error('Timer container not found!');
        return;
    }
    console.log('Applying position:', position);
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
            console.warn('Unknown position:', position, 'defaulting to bottom-right');
            container.style.bottom = '10px';
            container.style.right = '10px';
    }
    console.log('Applied styles:', container.style.cssText);
}

function startTimer(index, duration) {
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
            setTimeout(() => stopTimer(index), 5000); // Hide after 5 seconds
        }
    }
}