// From https://en.wikibooks.org/wiki/Designing_Sound_in_SuperCollider/Bubbles

// sound of a bubble
(
SynthDef(\bubblebub, {	|out=0, t_trig=0, attack=0.01, decay=0.08, pitchcurvelen=0.1, freq=500, doneAction=0, amp=0.1|
	var pitch, son;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.003), t_trig, doneAction: doneAction);
	pitch = freq * EnvGen.ar(Env.new([0,0,1],[0,1]).exprange(1, 2.718), t_trig, timeScale: pitchcurvelen);
	son = SinOsc.ar(pitch);
	// high-pass to remove any lowpitched artifacts, scale amplitude
	son = HPF.ar(son, 500) * amp * 10;
	Out.ar(out, son);
}).store
)

x = Synth(\bubblebub);
x.set(\t_trig, 1);
x.free;

// Sequence
(
p = Pbind(
	\instrument, \bubblebub,
	\sizefactor, Pwhite(0.3,1,inf),
	\dur, Pgauss(0.3, 0.2),
	\freq,  Pkey(\sizefactor).linexp(0, 1, 500, 600),
	\amp ,  Pkey(\sizefactor).linlin(0, 1, 0.15, 0.04),
	\decay, Pkey(\sizefactor).linlin(0, 1, 0.05, 0.08),
	\doneAction, 2
).play
)
p.stop

// http://supercollider.sourceforge.net/audiocode-examples/
// Babbling Brook from James McCartney (Creator)
{
({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 14)
* 400 + 500, 0.03, 0.003)}!2)
+ ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
* 800 + 1000, 0.03, 0.005)}!2)
* 4
}.play