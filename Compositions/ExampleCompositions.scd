Quarks.gui
// http://supercollider.sourceforge.net/audiocode-examples/
// Composition Examples

// Computer Phasing

// Lance Putnam
(play{SinOsc.ar(OnePole.ar(Mix(
LFSaw.ar([1,0.99],[0,0.6],2000,2000).trunc([400,600])*[1,-1]
),0.98)).dup*0.1}
)

// 8 Bit

// Need f0plugins to run: https://www.fredrikolofsson.com/pages/code-sc.html
// Simple synth definition using the Atari2600 UGen:
(
SynthDef(\atari2600, {|out= 0, gate= 1, tone0= 5,
tone1= 8, freq0= 10, freq1= 20, amp= 1, pan= 0|
var e, z;
e= EnvGen.kr(Env.asr(0.01, amp, 0.05), gate, doneAction:2);
z= Atari2600.ar(tone0, tone1, freq0, freq1, 15, 15);
Out.ar(out, Pan2.ar(z*e, pan));
}).store
)

 // And a pattern to play it:
(
Pbind(
\instrument, \atari2600,
\dur, Pseq([0.25, 0.25, 0.25, 0.45], inf),
\amp, 0.8,
\tone0, Pseq([Pseq([2, 5], 32), Pseq([3, 5], 32)], inf),
\tone1, 14,
\freq0, Pseq([Pbrown(28, 31, 1, 32),
Pbrown(23, 26, 3, 32)], inf),
\freq1, Pseq([Pn(10, 16), Pn(11, 16)], inf)
).play
)


// hamburg soft frog loops, by Julian Rohrhuber July 2005
// Published under the Creative Commons licence
// creativecommons.org/licenses/by/2.0/
(
[\kr, \ar].do { |x|
	SynthDef("softfrog_"++x, {
arg out, freq=440, prate=180, pwidth=0.5,
sustain=0.3, amp=0.1;
var env, u;
env = Env.linen(Rand(0.001, 0.003), Rand(0.1, 0.3), 0.01);
freq = freq + LFNoise2.kr(5, 10);
u = SinOsc.ar(
freq,
LFPulse.perform(x,
prate,
0,
Line.kr(pwidth, 0, sustain)
),
amp
);
u = BRF.ar(u, freq, 0.1) * EnvGen.kr(env, doneAction:2);
Out.ar(out, Pan2.ar(u, Rand(-1,1)))
}).store;

};
)


(
var arr, arr2, arr3, arr4, arfill, prob, node1, node2;
var dt = 1/8;
var n = 16;
arfill = { arr = Array.fill(n div: 2, { 180 + 180.5.rand2 }) };
arr2 = Array.fill(n, { rrand(1, pi) });
arr3 = Array.fill(n, { 1300 + 100.rand2 });
arr4 = Array.fill(n, {
if(0.6.coin, { 0.5.rand } , { 0.1.rand })  });
prob = [4,1].normalizeSum;

node1 = NodeProxy.audio(s, 2);
node2 = NodeProxy.audio(s, 2);
node2.source = { RLPF.ar(node1.ar, LFNoise2.kr(3).range(300,
MouseY.kr(300, 10000, 1)), 0.5) };
node2.play;

fork {
inf.do {|i|
if(i % 64 == 0) { arfill.value };
Synth(["softfrog_kr", "softfrog_ar"].wchoose(prob),
[
\out, node1.index,
\freq, arr3 @@ i,
\prate, arr @@ i,
\pwidth, arr2 @@ i,
\amp, arr4 @@ i
]
);
dt.wait;
}
};

 CmdPeriod.doOnce { node2.clear; node1.clear };
)