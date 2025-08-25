// Chargé par <script type="module" src="pose.js"></script> dans index.html
// Utilise le CDN @mediapipe/tasks-vision
// Dessine en temps réel les landmarks sur un canvas.

import {
  PoseLandmarker,
  FilesetResolver,
  DrawingUtils
} from 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.7';

let landmarker, running = false, video, canvas, ctx, utils, rafId;

async function createLandmarker() {
  const resolver = await FilesetResolver.forVisionTasks(
    // charge les assets wasm depuis le CDN officiel
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.7/wasm'
  );
  landmarker = await PoseLandmarker.createFromOptions(resolver, {
    baseOptions: {
      modelAssetPath: 'https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task',
    },
    runningMode: 'VIDEO',
    numPoses: 1,
  });
}

async function start(containerId) {
  if (running) return;
  running = true;

  if (!landmarker) await createLandmarker();

  const container = document.getElementById(containerId);
  container.innerHTML = '';

  video = document.createElement('video');
  video.setAttribute('playsinline', 'true');
  video.autoplay = true;
  video.muted = true;
  video.style.width = '100%';
  video.style.height = '100%';
  video.style.objectFit = 'cover';

  canvas = document.createElement('canvas');
  canvas.style.position = 'absolute';
  canvas.style.left = '0';
  canvas.style.top = '0';
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  ctx = canvas.getContext('2d');

  // conteneur relatif -> overlay absolu
  container.appendChild(video);
  container.appendChild(canvas);
  utils = new DrawingUtils(ctx);

  // Caméra
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { facingMode: { ideal: 'environment' } },
    audio: false
  });
  video.srcObject = stream;

  await video.play();
  resizeCanvasToVideo();

  const loop = async () => {
    if (!running) return;
    const nowMs = performance.now();
    // Détection
    const result = await landmarker.detectForVideo(video, nowMs);
    // Redessine
    draw(result);
    rafId = requestAnimationFrame(loop);
  };
  loop();

  window.addEventListener('resize', resizeCanvasToVideo);
}

function resizeCanvasToVideo() {
  if (!video || !canvas) return;
  const rect = video.getBoundingClientRect();
  canvas.width = rect.width;
  canvas.height = rect.height;
}

function draw(result) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  if (!result || !result.landmarks || result.landmarks.length === 0) return;

  // Les landmarks sont en pixels aux dimensions vidéo
  // Les DrawingUtils gèrent le mapping sur le canvas courant
  for (const lm of result.landmarks) {
    utils.drawLandmarks(lm, { radius: 3, color: 'rgba(102, 255, 178, 0.9)' });
    utils.drawConnectors(lm, PoseLandmarker.POSE_CONNECTIONS, { lineWidth: 3, color: 'rgba(0, 255, 170, 0.8)' });
  }
}

async function stop() {
  running = false;
  if (rafId) cancelAnimationFrame(rafId);
  if (video && video.srcObject) {
    const tracks = video.srcObject.getTracks();
    tracks.forEach(t => t.stop());
  }
}

window.KaisenPose = { start, stop };
