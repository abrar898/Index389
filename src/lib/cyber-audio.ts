// Cyberpunk / Mr. Robot Web Audio Synthesizer Engine
// Generates live authentic mechanical keystrokes & optional dark cyberpunk music

class CyberAudioEngine {
  private ctx: AudioContext | null = null;
  private isMusicPlaying = false;
  private currentStep = 0;
  private timerId: number | null = null;
  private masterMusicGain: GainNode | null = null;
  private filterNode: BiquadFilterNode | null = null;
  private noiseBuffer: AudioBuffer | null = null;

  private bpm = 124;
  private get stepTime() {
    return 60 / this.bpm / 4;
  }

  // A minor dark arpeggio notes
  private arpNotes = [
    220.0, 261.63, 329.63, 392.0, 440.0, 392.0, 329.63, 261.63,
    174.61, 220.0, 261.63, 329.63, 349.23, 329.63, 261.63, 220.0,
  ];

  // Bass roots: A1, F1, G1, E1
  private bassNotes = [55.0, 55.0, 43.65, 43.65, 49.0, 49.0, 41.2, 41.2];

  public init(): AudioContext | null {
    if (typeof window === "undefined") return null;
    try {
      if (!this.ctx) {
        const AudioCtx =
          window.AudioContext ||
          (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
        if (AudioCtx) {
          this.ctx = new AudioCtx();
        }
      }
      if (this.ctx && this.ctx.state === "suspended") {
        this.ctx.resume().catch(() => {});
      }

      // Generate 0.1s white noise buffer for realistic mechanical keyboard switch click
      if (this.ctx && !this.noiseBuffer) {
        const bufferSize = Math.floor(this.ctx.sampleRate * 0.08);
        const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (bufferSize * 0.25));
        }
        this.noiseBuffer = buffer;
      }

      // Music Master Bus
      if (this.ctx && !this.masterMusicGain) {
        this.masterMusicGain = this.ctx.createGain();
        this.masterMusicGain.gain.setValueAtTime(0.24, this.ctx.currentTime);

        this.filterNode = this.ctx.createBiquadFilter();
        this.filterNode.type = "lowpass";
        this.filterNode.frequency.setValueAtTime(800, this.ctx.currentTime);
        this.filterNode.Q.setValueAtTime(3.5, this.ctx.currentTime);

        this.filterNode.connect(this.masterMusicGain);
        this.masterMusicGain.connect(this.ctx.destination);
      }
    } catch (e) {
      console.warn("CyberAudio init error:", e);
    }
    return this.ctx;
  }

  // --- Real Hacker Mechanical Keystroke Sound Generator ---
  public playKeyClick(type?: string) {
    const ctx = this.init();
    if (!ctx) return;
    if (ctx.state === "suspended") {
      ctx.resume().catch(() => {});
    }

    try {
      const now = ctx.currentTime;

      // 1. Mechanical switch transient noise burst
      if (this.noiseBuffer) {
        const noiseSource = ctx.createBufferSource();
        noiseSource.buffer = this.noiseBuffer;

        const noiseFilter = ctx.createBiquadFilter();
        noiseFilter.type = "bandpass";
        noiseFilter.frequency.setValueAtTime(2400 + Math.random() * 800, now);
        noiseFilter.Q.setValueAtTime(2, now);

        const noiseGain = ctx.createGain();
        const baseGain = type === "flag" ? 0.35 : 0.18;
        noiseGain.gain.setValueAtTime(baseGain, now);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);

        noiseSource.connect(noiseFilter);
        noiseFilter.connect(noiseGain);
        noiseGain.connect(ctx.destination);

        noiseSource.start(now);
      }

      // 2. Tactile actuation click (High-mid triangle chirp)
      const clickOsc = ctx.createOscillator();
      const clickGain = ctx.createGain();
      clickOsc.type = "triangle";
      clickOsc.frequency.setValueAtTime(1200 + Math.random() * 400, now);
      clickOsc.frequency.exponentialRampToValueAtTime(300, now + 0.035);

      clickGain.gain.setValueAtTime(0.12, now);
      clickGain.gain.exponentialRampToValueAtTime(0.001, now + 0.035);

      clickOsc.connect(clickGain);
      clickGain.connect(ctx.destination);
      clickOsc.start(now);
      clickOsc.stop(now + 0.035);

      // 3. Bottom-out mechanical switch "thock"
      const thockOsc = ctx.createOscillator();
      const thockGain = ctx.createGain();
      thockOsc.type = "sine";
      thockOsc.frequency.setValueAtTime(140 + Math.random() * 30, now);
      thockOsc.frequency.exponentialRampToValueAtTime(45, now + 0.045);

      thockGain.gain.setValueAtTime(0.15, now);
      thockGain.gain.exponentialRampToValueAtTime(0.001, now + 0.045);

      thockOsc.connect(thockGain);
      thockGain.connect(ctx.destination);
      thockOsc.start(now);
      thockOsc.stop(now + 0.045);

      // 4. Special Event SFX: Teletype / Success Beep for Root & Flags
      if (type === "flag" || type === "header" || type === "success") {
        const toneOsc = ctx.createOscillator();
        const toneGain = ctx.createGain();
        toneOsc.type = "sine";
        toneOsc.frequency.setValueAtTime(type === "flag" ? 1760 : 880, now + 0.02);
        toneOsc.frequency.setValueAtTime(type === "flag" ? 2200 : 1320, now + 0.08);

        toneGain.gain.setValueAtTime(0.2, now + 0.02);
        toneGain.gain.exponentialRampToValueAtTime(0.001, now + 0.18);

        toneOsc.connect(toneGain);
        toneGain.connect(ctx.destination);
        toneOsc.start(now + 0.02);
        toneOsc.stop(now + 0.18);
      }
    } catch {
      // Audio error suppressed safely
    }
  }

  // --- Background Music: Mr. Robot / Reels Cyber Soundtrack ---
  public toggleMusic(): boolean {
    const ctx = this.init();
    if (!ctx) return false;

    if (this.isMusicPlaying) {
      this.stopMusic();
      return false;
    } else {
      this.startMusic();
      return true;
    }
  }

  public startMusic() {
    const ctx = this.init();
    if (!ctx || this.isMusicPlaying) return;
    this.isMusicPlaying = true;
    this.currentStep = 0;

    const scheduleLoop = () => {
      if (!this.isMusicPlaying || !this.ctx) return;
      this.playStep(this.currentStep);
      this.currentStep = (this.currentStep + 1) % 32;
      this.timerId = window.setTimeout(scheduleLoop, this.stepTime * 1000);
    };

    scheduleLoop();
  }

  public stopMusic() {
    this.isMusicPlaying = false;
    if (this.timerId !== null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
  }

  public getIsMusicPlaying(): boolean {
    return this.isMusicPlaying;
  }

  private playStep(step: number) {
    if (!this.ctx || !this.filterNode) return;
    const now = this.ctx.currentTime;

    // Filter sweep for evolving cinematic feel
    const lfoFreq = 550 + Math.sin(step * 0.2) * 400;
    this.filterNode.frequency.setTargetAtTime(lfoFreq, now, 0.05);

    // 1. Kick drum every quarter note
    if (step % 4 === 0) {
      const kickOsc = this.ctx.createOscillator();
      const kickGain = this.ctx.createGain();

      kickOsc.type = "sine";
      kickOsc.frequency.setValueAtTime(140, now);
      kickOsc.frequency.exponentialRampToValueAtTime(38, now + 0.12);

      kickGain.gain.setValueAtTime(0.35, now);
      kickGain.gain.exponentialRampToValueAtTime(0.001, now + 0.13);

      kickOsc.connect(kickGain);
      kickGain.connect(this.ctx.destination);

      kickOsc.start(now);
      kickOsc.stop(now + 0.13);
    }

    // 2. Offbeat analog hi-hat
    if (step % 4 === 2) {
      const hatOsc = this.ctx.createOscillator();
      const hatGain = this.ctx.createGain();

      hatOsc.type = "square";
      hatOsc.frequency.setValueAtTime(3400 + Math.random() * 300, now);

      hatGain.gain.setValueAtTime(0.045, now);
      hatGain.gain.exponentialRampToValueAtTime(0.001, now + 0.03);

      hatOsc.connect(hatGain);
      hatGain.connect(this.ctx.destination);

      hatOsc.start(now);
      hatOsc.stop(now + 0.03);
    }

    // 3. Dark Sawtooth Bassline
    if (step % 2 === 0) {
      const bassIndex = Math.floor(step / 4) % this.bassNotes.length;
      const bassFreq = this.bassNotes[bassIndex];

      const bassOsc = this.ctx.createOscillator();
      const bassGain = this.ctx.createGain();

      bassOsc.type = "sawtooth";
      bassOsc.frequency.setValueAtTime(bassFreq, now);

      bassGain.gain.setValueAtTime(0.16, now);
      bassGain.gain.exponentialRampToValueAtTime(0.001, now + this.stepTime * 1.6);

      bassOsc.connect(this.filterNode);
      bassGain.connect(this.filterNode);

      bassOsc.start(now);
      bassOsc.stop(now + this.stepTime * 1.6);
    }

    // 4. Hypnotic 16th-Note Cyber Arp
    const arpFreq = this.arpNotes[step % this.arpNotes.length];
    const arpOsc = this.ctx.createOscillator();
    const arpGain = this.ctx.createGain();

    arpOsc.type = "triangle";
    arpOsc.frequency.setValueAtTime(arpFreq, now);

    arpGain.gain.setValueAtTime(0.12, now);
    arpGain.gain.exponentialRampToValueAtTime(0.001, now + this.stepTime * 1.1);

    arpOsc.connect(this.filterNode);
    arpGain.connect(this.filterNode);

    arpOsc.start(now);
    arpOsc.stop(now + this.stepTime * 1.1);
  }
}

export const cyberAudio = new CyberAudioEngine();
