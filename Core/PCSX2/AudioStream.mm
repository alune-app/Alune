//
//  AudioStream.mm
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include "pcsx2/Host/AudioStream.h"

std::unique_ptr<AudioStream>
AudioStream::CreateOboeAudioStream(unsigned int, AudioStreamParameters const &,
                                   bool, Error *) {
  return nullptr;
}
