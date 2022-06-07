# smsdroid
Simple android cli sms reader and sender

## usage

    Help menu

    send sms usage and example:
    	smsdroid.sh <sim card slot number> <+e164 destination number> <message between quotes>
    	smsdroid.sh --send 0 +551122223333 "my message here"

    read sms example:
    	smsdroid.sh --read

## Caveats

SMS Service Center common numbers from Brasil:

> Números de centro de mensagens SMS
>
> TIM: +5521981138200;

> Claro: +5551991115300;

> Vivo: +550101102010; +550112102073 ;

> Oi: +550310000010;

> Brt: +550160000060.
