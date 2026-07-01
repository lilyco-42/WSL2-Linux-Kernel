savedcmd_scripts/unifdef := gcc -Wp,-MMD,scripts/.unifdef.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu11       -o scripts/unifdef scripts/unifdef.c   

source_scripts/unifdef := scripts/unifdef.c

deps_scripts/unifdef := \

scripts/unifdef: $(deps_scripts/unifdef)

$(deps_scripts/unifdef):
