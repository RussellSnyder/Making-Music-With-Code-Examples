// from https://lukaprincic.si/development-log/a-simple-808-beat-with-an-immature-bass-sound
// Daily Beat #1 - 5. August 2018
// this code is (c) Luka Prinčič and licenced under conditions of
// GNU GPL & Creative Commons BY-SA 4.0 licence


( // run this to load samples and SynthDefs ///

postln("
==============================================
>>> Hello Daily Beats!
");

Server.default.waitForBoot {

	// where are we?
	var dir = PathName(thisProcess.nowExecutingPath).pathOnly;

	// load samples
	~sampleSmp = PathName(dir +/+ "smp/").files;
	~sampleBfrList = List();
	~sampleBfr = List();
	postln(" \n~~~ Freeing buffers ..." );
	s.freeAllBuffers; // clean slate just in case
	postln("~~~ Loading samples ..." );
	~sampleSmp.do({ |item, i|
		postln("   " + i + "" + item.folderName +/+ item.fileName);
		~sampleBfrList.add(item.fileName); // this is collection of filenames
		// actually load into Buffers
		~sampleBfr.add(Buffer.readChannel(s, item.fullPath, channels:[0])); // [0] forces mono!
	});


	SynthDef("smpPlayer", { |out = 0, bufnum = 0, amp = 0.5 |
		var sound;

		sound = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), doneAction: Done.freeSelf);

		Out.ar([0,1], sound * amp);

		postln("\n~~~ Loaded smpPlayer ..." );
	}).add;


	// a quick hack, could be much improved
	SynthDef("bass", { |out, midi = 32 , amp = 0.9, nharms = 10, pan =0, gate = 1 |
		var audio = Blip.ar(midi.midicps, nharms, amp);
		var env = Linen.kr(gate, doneAction: Done.freeSelf);
		OffsetOut.ar(out, Pan2.ar(audio, pan, env));

	}).add;


};

)




( // run this to start the patterns and sound

TempoClock.default.tempo = 160/60;

~bass = Pbind(\instrument, \bass,
	\amp,				0.5,
	\nharms,            Pseq([4, 5, 2], inf),
    \dur,               Pseq([2, 1], 5),
	\midi, 				Pseq([32,Pshuf([32,44,47,23])], inf)
);

// to make it a bit more 'semantic' - buffer numbers to variables
~bdB = 0;
~snB = 1;
~clB = 2;
~hhB = 3;
~ohB = 4;


~bd = Pbind(\instrument, \smpPlayer, \bufnum, ~bdB, \amp, 0.7,
	\dur, Pseq([3.4,0.6,4], 2)
);

~sn = Pbind(\instrument, \smpPlayer, \bufnum, ~snB,	\amp, 0.7,
	\dur, Pseq([Rest(2),2], 4)
);

~hh = Pbind(\instrument, \smpPlayer, \bufnum, ~hhB,	\amp, 0.8,
	\dur, Pseq([
		Pseq([1.1/3,0.9/3], 6),
		Pseq([1/4],16),
		Pseq([1.1/3,0.9/3], 5), Pseq([1/6],4),
		Pseq([1/4],16)
	])
);

~oh = Pbind(\instrument, \smpPlayer, \bufnum, ~ohB,	\amp, 0.5,
	\dur, Pseq([Rest(7),1], 2),
);

~cl = Pbind(\instrument, \smpPlayer, \bufnum, ~clB,	\amp, 0.5,
	\dur, Pseq([Rest(4.5),3.5], 2),
);

~part1 = Ppar([~bd, ~sn, ~hh, ~oh, ~cl, ~bass], 8);

~part1.play;


)




