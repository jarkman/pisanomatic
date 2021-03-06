/* pisano_full_fat --- generate polyphonic melodies from Pisano numbers */

#include <avr/io.h>
#include "notes.h"

/////////////////////////////////////////////////////////////
// here we define how many parallel pisano generators we need
//
// Multiple generators can co-exist side by side. Each generating
// their own note sequences that harmonise with one another (or not)
#define PISANO_GENERATORS (3)
#define MAXSENSORS        (5)
#define OCTAVE            (12)

//#define SIMULATE_TRIGGERS  // turn on to test when we don't have input hardware

/////////////////////////////////////////////////////////////
//globals for pisano generator

unsigned short int pisanoNoteTable[24][PISANO_GENERATORS];
// stores notes that user wants to include in the composition

unsigned short int pisanoModulo[PISANO_GENERATORS];
// used for modulo arithmetic

unsigned short int pisanoNotes[PISANO_GENERATORS];
// keeps track of how many notes user programmed

signed short int pisanoCircBuffer[3][PISANO_GENERATORS];
// (must be signed) 3 element circular buffer, used for the Pisano sequence generator

unsigned short int pisanoVoice[PISANO_GENERATORS];
// Voices for the notes generated by the Pisano sequence

unsigned short int pisanoVolumeDelta[PISANO_GENERATORS];
// Volume Deltas for the notes generated by the Pisano sequence
unsigned short int pisanoVibratoPercent[PISANO_GENERATORS];
// Vibrato Percents for the notes generated by the Pisano sequence
unsigned short int pisanoEnvelope[PISANO_GENERATORS];
// Amplitude envelope for the notes generated by the Pisano sequence
////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
// for pisano generator - function definitions
void pisanoReset (unsigned short int which_generator)
{
  // Some of the text messages are  commented out to save RAM,
  // which is critical for success on an ATmega168 Arduino
  unsigned short int i;
  
  ///////////////////////////////////////////////////
  // inform the user which generator we're resetting
  //Serial.print ("OK: using generator ");
  //Serial.print (which_generator,DEC);
  //Serial.print ("\n");

  ////////////////////////////////////////////
  // initialise note lookup table with all zeros
  for (i = 0; i < 24; i++) {
     pisanoNoteTable[i][which_generator] = 0;
  }
  //Serial.print ("OK: reset user notes scale\n");

  ////////////////////////////////////////////
  // reset the number of user programmed notes
  pisanoModulo[which_generator] = 0;
  pisanoNotes[which_generator] = 0;

  // Reset the voice for this generator
  pisanoVoice[which_generator] = VOICE_SINE;
  pisanoVolumeDelta[which_generator] = 600;
  pisanoVibratoPercent[which_generator] = 0;
  pisanoEnvelope[which_generator] = ENVELOPE_LINEAR;
  
  ////////////////////////////////////////////
  // initialise pisano sequence generator such that
  // the first number produced is zero
  pisanoCircBuffer[0][which_generator] = 0;
  pisanoCircBuffer[1][which_generator] = -1;
  pisanoCircBuffer[2][which_generator] = 1;
  Serial.print ("OK: reset pisano generator ");
  Serial.print (which_generator, DEC);
  Serial.print ("\n");
}


/* pisanoInit --- (re)initialise the Pisano sequence */

void pisanoInit (int which_generator)
{
  ////////////////////////////////////////////
  // initialise pisano sequence generator such that
  // the first number produced is zero
  if ((which_generator >= 0) && (which_generator < PISANO_GENERATORS)) {
    pisanoCircBuffer[0][which_generator] = 0;
    pisanoCircBuffer[1][which_generator] = -1;
    pisanoCircBuffer[2][which_generator] = 1;
  }
}


/* pisanoAddMIDINote --- add a MIDI note to the set used by a given Pisano generator */

void pisanoAddMIDINote (unsigned short int which_generator, unsigned short int note_user_clicked)
{
    ////////////////////////////////////////
    // store the note in the lookup table
    
    // there's a pisanoModulo for each generator
    // and a pisanoNoteTable for each generator too
    pisanoNoteTable[ pisanoModulo[which_generator] ][which_generator] = note_user_clicked;

    //////////////////////////////////////////////
    // keep track of how many notes we've stored for this generator
    pisanoModulo[which_generator]++;
    pisanoNotes[which_generator]++;
 
    //////////////////////////////////////////////
    // here we impose an arbitrary two octave (24 note) limit 
    // upper practical limit is the 128 available midi note values
    if (pisanoModulo[which_generator] > 24) {
//      Serial.print ("eek! You've entered more notes than we can store. Truncating!\n");
      Serial.print ("Truncating!\n");
      pisanoModulo[which_generator] = 24;
      pisanoNotes[which_generator] = 24;
    }
}


/* pisanoRemoveNote --- shorten the Pisano sequence by removing a note */

void pisanoRemoveNote (unsigned short int which_generator)
{
  if (pisanoModulo[which_generator] > 1)
    pisanoModulo[which_generator]--;
    
  Serial.print ("remove note ");
  Serial.print (which_generator, DEC);
  Serial.print (" ");
  Serial.print (pisanoModulo[which_generator]);
  Serial.print ("\n");
}


/* pisanoReinstateNote --- lengthen the Pisano sequence by adding a note */

void pisanoReinstateNote (unsigned short int which_generator)
{
  if (pisanoModulo[which_generator] < pisanoNotes[which_generator])
    pisanoModulo[which_generator]++;
    
  Serial.print ("reinstate note ");
  Serial.print (which_generator, DEC);
  Serial.print (" ");
  Serial.print (pisanoModulo[which_generator]);
  Serial.print ("\n");
}


/* pisanoSetVoice --- set the voice to be used for a given Pisano generator */

void pisanoSetVoice (unsigned short int which_generator, unsigned short int voice)
{
  if ((which_generator >= 0) && (which_generator < PISANO_GENERATORS))
    pisanoVoice[which_generator] = voice;
}


/* pisanoSetVolumeDelta --- set the volume delta to be used for a given Pisano generator */

void pisanoSetVolumeDelta (unsigned short int which_generator, unsigned short int volumeDelta)
{
  if ((which_generator >= 0) && (which_generator < PISANO_GENERATORS))
    pisanoVolumeDelta[which_generator] = volumeDelta;
}


/* pisanoSetVibratoPercent --- set the vibrato percent to be used for a given Pisano generator */

void pisanoSetVibratoPercent (unsigned short int which_generator, unsigned short int vibratoPercent)
{
  if ((which_generator >= 0) && (which_generator < PISANO_GENERATORS))
    pisanoVibratoPercent[which_generator] = vibratoPercent;
}


/* pisanoSetEnvelope --- set the envelope to be used for a given Pisano generator */

void pisanoSetEnvelope (unsigned short int which_generator, unsigned short int envelope)
{
  if ((which_generator >= 0) && (which_generator < PISANO_GENERATORS))
    pisanoEnvelope[which_generator] = envelope;
}


/* pisanoGenerateNote --- generate a note corresponding to the next Pisano number */

void pisanoGenerateNote (unsigned short int which_generator)
{
  unsigned short int midi_note;
  unsigned short int i;

  ////////////////////////////////////////////////
  // compute addition part of the Pisano sequence
  // display some useful information onscreen
  pisanoCircBuffer[0][which_generator] = 
                  pisanoCircBuffer[1][which_generator] + pisanoCircBuffer[2][which_generator];
  
  // pisano generator number
  Serial.print ("Pisano");
  Serial.print (which_generator,DEC);
  Serial.print (": [");
  
  // each element
  for (i = 0; i < 3; i++) {
    Serial.print (pisanoCircBuffer[i][which_generator], DEC);
    if (i < 2)    
      Serial.print (", ");
  }
  Serial.print ("] ");

  /////////////////////////////////
  // compute the modulo arithmetic part
  pisanoCircBuffer[0][which_generator] %= pisanoModulo[which_generator];

  //////////////////////////////////////////////////////////
  // use the now-modulo'd pisano number to extract a note from the table
  midi_note = pisanoNoteTable[ pisanoCircBuffer[0][which_generator] ][which_generator];

  Serial.print (midi_note, DEC);
  Serial.print (" ");

  switch (midi_note % 12) {
  case 0:
    Serial.print ("C");
    break;
  case 1:
    Serial.print ("C#");
    break;
  case 2:
    Serial.print ("D");
    break;
  case 3:
    Serial.print ("D#");
    break;
  case 4:
    Serial.print ("E");
    break;
  case 5:
    Serial.print ("F");
    break;
  case 6:
    Serial.print ("F#");
    break;
  case 7:
    Serial.print ("G");
    break;
  case 8:
    Serial.print ("G#");
    break;
  case 9:
    Serial.print ("A");
    break;
  case 10:
    Serial.print ("A#");
    break;
  case 11:
    Serial.print ("B");
    break;
  }
  Serial.print ((midi_note / 12) - 2, DEC); 
  Serial.print ("\n");
  
  /////////////////////////////////////
  //find a 'spare' oscillator whose volume is zero - start playing
  
  /*
  for( i = 0; i < NOTES; i ++ )
    if (noteFinished(i)){
      // we're being a bit sneaky by probing the noteVolume[] array
      // this  is NOT a pisano component but rather an internal part of
      // the audio generation code in notes.pde and notes.h
      startNote(i, midi_note, decay, 0);
      break;// after we've found a spare oscillator - stop searching
    }
    // if we can't find one - just don't play anything
    
  */
  
  /*
  // use the quiestest note:
  i = quietestNote();
  startNote(i, midi_note, decay, 100, 25);
  */
  
  // give each generator its own voice, using variable vibrato to distinguish the voices:
  //startNote( int oscillators, int midiNoteNumber, int voice, int volumeDelta, int envelope, int sweepMillisecs , int vibratoPercent );
  startNote (which_generator, midi_note, pisanoVoice[which_generator], pisanoVolumeDelta[which_generator], pisanoEnvelope[which_generator], 7, pisanoVibratoPercent[which_generator]);
  
  ///////////////////////////////////////////////////////
  // circular buffer - keep track of the previous numbers
  pisanoCircBuffer[1][which_generator] = pisanoCircBuffer[2][which_generator];
  pisanoCircBuffer[2][which_generator] = pisanoCircBuffer[0][which_generator];
}


/* setup --- do all the initialisation for the sketch */

void setup ()
{
  Serial.begin (9600); // for debugging

  setupNotes ();
  
  //////////////////////////////////////////////////////////
  // for pisano generator
    
  //simulate user programming a scale into the generator
  pisanoReset (0); // then reset generator 0
  pisanoReset (1); // then reset generator 1
  pisanoReset (2); // then reset generator 2
  
  pisanoSetVoice (0, VOICE_SAWTOOTH);
  pisanoSetVoice (1, VOICE_SINE);
  pisanoSetVoice (2, VOICE_VIBRA);
  
  pisanoSetVolumeDelta (0, 600);
  pisanoSetVolumeDelta (1, 600);
  pisanoSetVolumeDelta (2, 300);
  
  pisanoSetVibratoPercent (0, 15);
  
  pisanoSetEnvelope (0, ENVELOPE_SUSTAIN);
  pisanoSetEnvelope (1, ENVELOPE_EXP);
  pisanoSetEnvelope (2, ENVELOPE_TREMOLO);
  
  ///////////////////////
  // simultaneous scales!
  // c# and d# pentatonic
  ///////////////////////
  
  // sequence lengths 16,20,24
  
  // c# pentatonic scale
  // starting from c#
  // - extending 1 note extra past the octave
  // 7 notes total - produces sequence of 16 notes
  pisanoAddMIDINote (0, 61);
  pisanoAddMIDINote (0, 64);
  pisanoAddMIDINote (0, 66);
  pisanoAddMIDINote (0, 68);
  pisanoAddMIDINote (0, 71);
  pisanoAddMIDINote (0, 73);
  pisanoAddMIDINote (0, 76);
  
  // c# pentatonic scale
  // starting from f#
  // 5 notes total - produces sequence of 20 notes
  pisanoAddMIDINote (1, 66 + OCTAVE);
  pisanoAddMIDINote (1, 68 + OCTAVE);
  pisanoAddMIDINote (1, 71 + OCTAVE);
  pisanoAddMIDINote (1, 73 + OCTAVE);
  pisanoAddMIDINote (1, 76 + OCTAVE);
  
  // d# pentatonic scale
  // starting from d# and repeating at the octave
  // 6 notes total - produces a sequence of 24 notes
  pisanoAddMIDINote (2, 63 - (2 * OCTAVE));
  pisanoAddMIDINote (2, 66 - (2 * OCTAVE));
  pisanoAddMIDINote (2, 68 - (2 * OCTAVE));
  pisanoAddMIDINote (2, 71 - (2 * OCTAVE));
  pisanoAddMIDINote (2, 73 - (2 * OCTAVE));
  pisanoAddMIDINote (2, 75 - (2 * OCTAVE));    
  
  // setup input pins
#ifdef PHILL_INPUT    
  pinMode (10,INPUT);
  pinMode (8,INPUT);
#else
  pinMode (2, INPUT);
  pinMode (4, INPUT);
  pinMode (5, INPUT);
  pinMode (6, INPUT);
  pinMode (7, INPUT);
#endif    
}


void loop ()
{
#ifdef SIMULATE_TRIGGERS    
  simulateTriggers ();
#else
  /*****************************************************************/

#ifdef PHILL_INPUT
  //Phill's two-sensor thing:
  
   // loop around checking pins 8 and 10
   
   //trigger generator 0 if pin 8 is high
   //trigger generator 1 if pin 10 is high
  
  if ( (PINB & 1) == 1) {
    //trigger generator 0 if pin 8 is high
    pisanoGenerateNote(0); 
   }
  
  if ( (PINB & 4) == 4 ) {
    // trigger generator 1 if pin 10 is high 
    pisanoGenerateNote(1); 
  }
#else  /* PHILL_INPUT */
  // John's sensor detection:
  
  // Switches on some of the digital input pins
  static int sw[MAXSENSORS] = {5, 6, 7, 2, 4};
  // Previous state of the input pins
  static int prev[MAXSENSORS] = {0, 0, 0, 0, 0};
  int i;
  int cur;
  
  // Read each input in turn, looking for changes
  for (i = 0; i < MAXSENSORS; i++) {
    cur = digitalRead (sw[i]);
    if (cur != prev[i]) {
      if (cur == 0)        // Trigger when LOW
        switch (i) {
        case 0:
        case 1:
        case 2:
          pisanoGenerateNote (i);
          break;
        case 3:
          pisanoRemoveNote (1);
          pisanoInit (1);
          break;
        case 4:
          // Future expansion (handlebar switches, etc.)
//          pisanoReinstateNote (1);
//          pisanoInit (1);
          break;
        }
        
      prev[i] = cur;
    }
  }
  
  // Small delay for debouncing (may not be needed for optical sensors)
  delay (20);
#endif /* PHILL_INPUT */

#endif
}

#ifdef SIMULATE_TRIGGERS  
void simulateTriggers()
{
  long now = millis();
  static long lastTrigger[ PISANO_GENERATORS ];
  
  for( int i = 0; i < PISANO_GENERATORS; i ++ )
  {
    if( now < lastTrigger[i] ) // must be first time
      lastTrigger[i] = now;
      
    if( now > lastTrigger[i] + 800l + (100*i)) // start at non-overlapping times
    {
      pisanoGenerateNote(i);
      lastTrigger[i] = now;
    }
  }
}
#endif

