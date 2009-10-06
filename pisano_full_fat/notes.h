/* notes.h --- header file for polyphonic note synthesis on Arduino */

#define NOTES (3)        // The maximum number of notes we can play simultaneously    
#define MAXVOICES (6)    // Maximum number of voices
#define MAXENVELOPES (6) // Maximum number of envelopes
#define NOTE_OVERFLOW_SHIFT 1  // increase this if turning up NOTES results in clipping - suggest 
// 4 -> 1
// 12 -> 2

// Turning these features on reduces the maximum workable value of NOTES !
//#define DO_OVERTONES  // turning this on makes the sound more interesting, but reduces the number of notes we can play to about 3
//#define DO_VIBRATO    // fixed vibrato on all notes
//#define DO_SWEEP      // sweep from one note to the next
//#define DO_ANTILOG    // I've no idea what this does, but it uses up RAM if switched on -- John

#define VOICE_SINE      (0)    // Simple sine wave
#define VOICE_SQUARE    (1)    // Simple square wave
#define VOICE_TRIANGLE  (2)    // Triangle wave
#define VOICE_SAWTOOTH  (3)    // Sawtooth wave
#define VOICE_BRASS     (4)    // Phill's sampled brass     
#define VOICE_VIBRA     (5)    // Phill's sampled vibraphone

#define ENVELOPE_LINEAR  (0)   // Linear decay to zero, as in original version
#define ENVELOPE_EXP     (1)   // Exponential decay, similar to a bell
#define ENVELOPE_GATE    (2)   // Simple on/off gating
#define ENVELOPE_ADSR    (3)   // Attack, decay, sustain, release
#define ENVELOPE_SUSTAIN (4)   // Short exponential attack and decay
#define ENVELOPE_TREMOLO (5)   // Like ADSR but with modulated sustain amplitude

extern uint16_t maxMidi;

extern void setupNotes (void);

extern void startNote (int note, int midiNoteNumber, int voice, int volumeDelta, int envelope, int sweepMillisecs, int vibratoPercent);
