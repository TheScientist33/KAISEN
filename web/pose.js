// pose.js (module)
import {
  PoseLandmarker,
  FilesetResolver,
  DrawingUtils
} from 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.7';

let landmarker, running = false, video, canvas, ctx, utils, rafId;

function status(text) {
  const hud = document.getElementById('hud');
  if (hud) hud.textContent = text;
  window.parent?.postMessage({ type: 'STATUS', text }, '*');
}

function angleDeg(ax, ay, bx, by, cx, cy) {
  const abx = ax - bx, aby = ay - by;
  const cbx = cx - bx, cby = cy - by;
  let r = Math.atan2(cby, cbx) - Math.atan2(aby, abx);
  let d = Math.abs(r * 180 / Math.PI);
  if (d > 180) d = 360 - d;
  return d;
}

async function createLandmarker() {
  const resolver = await FilesetResolver.forVisionTasks(
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.7/wasm'
  );
  landmarker = await PoseLandmarker.createFromOptions(resolver, {
    baseOptions: {
      // lite = plus rapide ; heavy = plus précis
      modelAssetPath:
        'https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task',
    },
    runningMode: 'VIDEO',
    numPoses: 1,
    minPoseDetectionConfidence: 0.6,
    minPosePresenceConfidence: 0.6,
    minTrackingConfidence: 0.6,
  });
}

function resizeCanvasToVideo() {
  if (!video || !canvas) return;
  // Utilise la taille “réelle” du flux pour éviter le flou
  canvas.width  = video.videoWidth  || canvas.clientWidth;
  canvas.height = video.videoHeight || canvas.clientHeight;
}

function draw(result) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  if (!result || !result.landmarks || result.landmarks.length === 0) {
    status('Pas de pose détectée…');
    return;
  }

  const lm = result.landmarks[0]; // 33 points
  utils.drawLandmarks(lm, { radius: 3, color: 'rgba(102,255,178,0.9)' });
  utils.drawConnectors(lm, PoseLandmarker.POSE_CONNECTIONS, { lineWidth: 3, color: 'rgba(0,255,170,0.8)' });

  // Indices MediaPipe: leftHip=23, leftKnee=25, leftAnkle=27 (coord. normalisées 0..1)
  const hip = lm[23], knee = lm[25], ankle = lm[27];
  if (hip && knee && ankle) {
    const a = angleDeg(hip.x, hip.y, knee.x, knee.y, ankle.x, ankle.y);
    status(`Angle genou (gauche): ${a.toFixed(0)}°`);
    window.parent?.postMessage({ type: 'POSE_ANGLE', angle: a }, '*');

    // Feedback côté Flutter (TTS) quand angle < 90°, cooldown 1.5s côté Flutter
    if (a < 90) {
      window.parent?.postMessage({ type: 'CUE', text: 'Redressez vos genoux !' }, '*');
    }
  } else {
    status('Pose détectée, genou gauche non fiable…');
  }
}

export async function start(containerId) {
  if (running) return;
  running = true;

  try {
    if (!landmarker) {
      status('Caméra OK — chargement du modèle…');
      await createLandmarker();
      status('✅ Modèle chargé');
    }

    const container = document.getElementById(containerId);
    video = document.getElementById('video');
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');
    utils = new DrawingUtils(ctx);

    // Caméra (front = 'user' ; back = 'environment')
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'user' }, // ← change en 'environment' si besoin
      audio: false
    });
    video.srcObject = stream;
    await video.play();

    resizeCanvasToVideo();
    video.addEventListener('loadedmetadata', resizeCanvasToVideo);
    window.addEventListener('resize', resizeCanvasToVideo);

    const loop = async () => {
      if (!running) return;
      const nowMs = performance.now();
      const result = await landmarker.detectForVideo(video, nowMs);
      draw(result);
      rafId = requestAnimationFrame(loop);
    };
    loop();
  } catch (e) {
    console.error(e);
    status('❌ ' + (e?.message || e));
  }
}

export async function stop() {
  running = false;
  if (rafId) cancelAnimationFrame(rafId);
  if (video && video.srcObject) {
    video.srcObject.getTracks().forEach(t => t.stop());
  }
}

window.KaisenPose = { start, stop };
