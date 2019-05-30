#ifndef GUIDANCE_MODULE_H
#define GUIDANCE_MODULE_H
#include <sys/stat.h>
#include <QObject>
#include <QString>
#include <QDebug>

#define SYS_LANGUAGE_INIT 0
#define SYS_LANGUAGE_JP   1
#define SYS_LANGUAGE_EN   2
#define TTSMAX (2048)

class Guidance_Module : public QObject
{
    Q_OBJECT
public:
    int g_voicelanguage = SYS_LANGUAGE_INIT;
    QString g_voice_module = "";
    Q_INVOKABLE void guidance(const QString &text){
        char tts_voice[TTSMAX];
        int len = 0;
        memset(tts_voice,0,TTSMAX);

        strncat(tts_voice, "sh flite '", (TTSMAX - len - 1));

        len = strlen(tts_voice);
        strncat(tts_voice, text.toUtf8().data(), (TTSMAX - len - 1));

        len = strlen(tts_voice);
        strncat(tts_voice, "'&", (TTSMAX - len - 1));

        system(tts_voice);
    }
};
#endif // GUIDANCE_MODULE_H
