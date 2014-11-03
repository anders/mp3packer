ifdef ComSpec
	#Windows
	O=.obj
	EXE=.exe
	EXLIBRARIES=Shell32.lib
	SSEOPT=
else
	#Other
	O=.o
	EXE=
	EXLIBRARIES=
	SSEOPT=-ccopt "-msse4.1"
endif


#common=-w "+a-4-9-32-35" -warn-error "+a-4-6-7-9-27-29-32..39" -warn-error "+a-4-9-32-35" $(SSEOPT) -thread unix.cmxa threads.cmxa str.cmxa $(EXLIBRARIES)
common=$(SSEOPT) -thread unix.cmxa threads.cmxa str.cmxa $(EXLIBRARIES)

ocaml=ocamlopt.opt $(common)


all: mp3packer mp3reader


.SUFFIXES: .ml .mli .cmo .cmi .cmx $O

.ml.cmx:
	$(ocaml) -c $<

.mli.cmi:
	$(ocaml) -c $<

ifdef ComSpec
.c$O:
	$(ocaml) -ccopt "/Fa$@.asm" -c $<
else
.c$O:
	$(ocaml) -ccopt "-save-temps" -c $<
endif


ALLREQS=ptr.cmx ptr-c$O crc.cmx list2.cmx expandarray.cmx c_part$O unicode.cmx unicode-c$O threadpool.cmx types.cmx p.cmx pack.cmx mp3read.cmx mp3write.cmx mp3info.cmx mp3framehuffman-c$O mp3framehuffman.cmx mp3frameutils-c$O mp3frameutils.cmx mp3queue.cmx



MP3PACKER=$(ALLREQS) mp3packer.cmx

# The -ffast-math line is only to prevent this from running on a 64-bit system. Use "make mp3packer64" instead
# That line has no bearing on the actual program; it may be removed if it causes problems
mp3packer: depend $(MP3PACKER)
	$(ocaml) -ffast-math
	$(ocaml) -o $@$(EXE) $(MP3PACKER)

# The fail_on_32bit line is only to prevent this from running on a 32-bit system. Use "make mp3packer" or just "make" instead
# The source is a .txt file since otherwise ocamldep would try to parse the file on the 32-bit build and fail
mp3packer64: depend $(MP3PACKER)
	$(ocaml) -c -impl fail_on_32bit.txt
	$(ocaml) -o $@$(EXE) $(MP3PACKER)


MP3READER=$(ALLREQS) mp3reader.cmx

mp3reader: depend $(MP3READER)
	$(ocaml) -o $@$(EXE) $(MP3READER)



test: depend $(ALLREQS) test.cmx
	$(ocaml) -o $@$(EXE) $(ALLREQS) test.cmx
	./test$(EXE)



clean:
	rm -f ./*$O ./*.cmi ./*.cmx ./*.cmo ./*.cma ./*.cmxa ./*.asm ./*.s ./*.i

depend:
	ocamldep *.mli *.ml > .depend

include .depend


