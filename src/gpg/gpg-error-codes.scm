;;; GPGME/G : GPGME with Guile
;;; 
;;; A Guile binding to the GPGME library
;;;
;;; Copyright © 2011 Atom X
;;;
;;; This library is free software: you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implide warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this library.  If not, see
;;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file defines all of the error codes provided by libgpg-error.
;; There are a great many of them!  All errors and their associated
;; numeric value have been extracted from <gpg-error.h> with a basic
;; transformation in the following vein:
;;
;;    GPG_ERR_[A-Z_]+[A-Z] -> gpg-err:[a-z-]+[a-z]
;;
;; Example: GPG_ERR_NO_VALUE -> gpg-err:no-value
;;
;; Every effort has been made to document each error code, but there
;; are invariably some omissions due to incomplete documentation
;; upstream.  Luckily, most of the errors listed below are _very_ rare
;; in the course of using GPGME/G, so hopefully things won't get too
;; cryptic.

;;; Code:

(use-modules (ice-9 vlist)
	     (srfi srfi-1)
	     (ice-9 popen)   		;\
	     (ice-9 rdelim)		; - for error descriptions
	     (ice-9 regex))		;/

(define *error-code-alist*
  (let ((sys-err (ash 1 15)))
    `((0 . gpg-err:no-error)
      (1 . gpg-err:general)
      (2 . gpg-err:unknown-packet)
      (3 . gpg-err:unknown-version)
      (4 . gpg-err:pubkey-algo)
      (5 . gpg-err:digest-algo)
      (6 . gpg-err:bad-pubkey)
      (7 . gpg-err:bad-seckey)
      (8 . gpg-err:bad-signature)
      (9 . gpg-err:no-pubkey)
      (10 . gpg-err:checksum)
      (11 . gpg-err:bad-passphrase)
      (12 . gpg-err:cipher-algo)
      (13 . gpg-err:keyring-open)
      (14 . gpg-err:inv-packet)
      (15 . gpg-err:inv-armor)
      (16 . gpg-err:no-user-id)
      (17 . gpg-err:no-seckey)
      (18 . gpg-err:wrong-seckey)
      (19 . gpg-err:bad-key)
      (20 . gpg-err:compr-algo)
      (21 . gpg-err:no-prime)
      (22 . gpg-err:no-encoding-method)
      (23 . gpg-err:no-encryption-scheme)
      (24 . gpg-err:no-signature-scheme)
      (25 . gpg-err:inv-attr)
      (26 . gpg-err:no-value)
      (27 . gpg-err:not-found)
      (28 . gpg-err:value-not-found)
      (29 . gpg-err:syntax)
      (30 . gpg-err:bad-mpi)
      (31 . gpg-err:inv-passphrase)
      (32 . gpg-err:sig-class)
      (33 . gpg-err:resource-limit)
      (34 . gpg-err:inv-keyring)
      (35 . gpg-err:trustdb)
      (36 . gpg-err:bad-cert)
      (37 . gpg-err:inv-user-id)
      (38 . gpg-err:unexpected)
      (39 . gpg-err:time-conflict)
      (40 . gpg-err:keyserver)
      (41 . gpg-err:wrong-pubkey-algo)
      (42 . gpg-err:tribute-to-d-a)
      (43 . gpg-err:weak-key)
      (44 . gpg-err:inv-keylen)
      (45 . gpg-err:inv-arg)
      (46 . gpg-err:bad-uri)
      (47 . gpg-err:inv-uri)
      (48 . gpg-err:network)
      (49 . gpg-err:unknown-host)
      (50 . gpg-err:selftest-failed)
      (51 . gpg-err:not-encrypted)
      (52 . gpg-err:not-processed)
      (53 . gpg-err:unusable-pubkey)
      (54 . gpg-err:unusable-seckey)
      (55 . gpg-err:inv-value)
      (56 . gpg-err:bad-cert-chain)
      (57 . gpg-err:missing-cert)
      (58 . gpg-err:no-data)
      (59 . gpg-err:bug)
      (60 . gpg-err:not-supported)
      (61 . gpg-err:inv-op)
      (62 . gpg-err:timeout)
      (63 . gpg-err:internal)
      (64 . gpg-err:eof-gcrypt)
      (65 . gpg-err:inv-obj)
      (66 . gpg-err:too-short)
      (67 . gpg-err:too-large)
      (68 . gpg-err:no-obj)
      (69 . gpg-err:not-implemented)
      (70 . gpg-err:conflict)
      (71 . gpg-err:inv-cipher-mode)
      (72 . gpg-err:inv-flag)
      (73 . gpg-err:inv-handle)
      (74 . gpg-err:truncated)
      (75 . gpg-err:incomplete-line)
      (76 . gpg-err:inv-response)
      (77 . gpg-err:no-agent)
      (78 . gpg-err:agent)
      (79 . gpg-err:inv-data)
      (80 . gpg-err:assuan-server-fault)
      (81 . gpg-err:assuan)
      (82 . gpg-err:inv-session-key)
      (83 . gpg-err:inv-sexp)
      (84 . gpg-err:unsupported-algorithm)
      (85 . gpg-err:no-pin-entry)
      (86 . gpg-err:pin-entry)
      (87 . gpg-err:bad-pin)
      (88 . gpg-err:inv-name)
      (89 . gpg-err:bad-data)
      (90 . gpg-err:inv-parameter)
      (91 . gpg-err:wrong-card)
      (92 . gpg-err:no-dirmngr)
      (93 . gpg-err:dirmngr)
      (94 . gpg-err:cert-revoked)
      (95 . gpg-err:no-crl-known)
      (96 . gpg-err:crl-too-old)
      (97 . gpg-err:line-too-long)
      (98 . gpg-err:not-trusted)
      (99 . gpg-err:canceled)
      (100 . gpg-err:bad-ca-cert)
      (101 . gpg-err:cert-expired)
      (102 . gpg-err:cert-too-young)
      (103 . gpg-err:unsupported-cert)
      (104 . gpg-err:unknown-sexp)
      (105 . gpg-err:unsupported-protection)
      (106 . gpg-err:corrupted-protection)
      (107 . gpg-err:ambiguous-name)
      (108 . gpg-err:card)
      (109 . gpg-err:card-reset)
      (110 . gpg-err:card-removed)
      (111 . gpg-err:inv-card)
      (112 . gpg-err:card-not-present)
      (113 . gpg-err:no-pkcs15-app)
      (114 . gpg-err:not-confirmed)
      (115 . gpg-err:configuration)
      (116 . gpg-err:no-policy-match)
      (117 . gpg-err:inv-index)
      (118 . gpg-err:inv-id)
      (119 . gpg-err:no-scdaemon)
      (120 . gpg-err:scdaemon)
      (121 . gpg-err:unsupported-protocol)
      (122 . gpg-err:bad-pin-method)
      (123 . gpg-err:card-not-initialized)
      (124 . gpg-err:unsupported-operation)
      (125 . gpg-err:wrong-key-usage)
      (126 . gpg-err:nothing-found)
      (127 . gpg-err:wrong-blob-type)
      (128 . gpg-err:missing-value)
      (129 . gpg-err:hardware)
      (130 . gpg-err:pin-blocked)
      (131 . gpg-err:use-conditions)
      (132 . gpg-err:pin-not-synced)
      (133 . gpg-err:inv-crl)
      (134 . gpg-err:bad-ber)
      (135 . gpg-err:inv-ber)
      (136 . gpg-err:element-not-found)
      (137 . gpg-err:identifier-not-found)
      (138 . gpg-err:inv-tag)
      (139 . gpg-err:inv-length)
      (140 . gpg-err:inv-keyinfo)
      (141 . gpg-err:unexpected-tag)
      (142 . gpg-err:not-der-encoded)
      (143 . gpg-err:no-cms-obj)
      (144 . gpg-err:inv-cms-obj)
      (145 . gpg-err:unknown-cms-obj)
      (146 . gpg-err:unsupported-cms-obj)
      (147 . gpg-err:unsupported-encoding)
      (148 . gpg-err:unsupported-cms-version)
      (149 . gpg-err:unknown-algorithm)
      (150 . gpg-err:inv-engine)
      (151 . gpg-err:pubkey-not-trusted)
      (152 . gpg-err:decrypt-failed)
      (153 . gpg-err:key-expired)
      (154 . gpg-err:sig-expired)
      (155 . gpg-err:encoding-problem)
      (156 . gpg-err:inv-state)
      (157 . gpg-err:dup-value)
      (158 . gpg-err:missing-action)
      (159 . gpg-err:module-not-found)
      (160 . gpg-err:inv-oid-string)
      (161 . gpg-err:inv-time)
      (162 . gpg-err:inv-crl-obj)
      (163 . gpg-err:unsupported-crl-version)
      (164 . gpg-err:inv-cert-obj)
      (165 . gpg-err:unknown-name)
      (166 . gpg-err:locale-problem)
      (167 . gpg-err:not-locked)
      (168 . gpg-err:protocol-violation)
      (169 . gpg-err:inv-mac)
      (170 . gpg-err:inv-request)
      (171 . gpg-err:unknown-extn)
      (172 . gpg-err:unknown-crit-extn)
      (173 . gpg-err:locked)
      (174 . gpg-err:unknown-option)
      (175 . gpg-err:unknown-command)
      (176 . gpg-err:not-operational)
      (177 . gpg-err:no-passphrase)
      (178 . gpg-err:no-pin)
      (179 . gpg-err:not-enabled)
      (180 . gpg-err:no-engine)
      (181 . gpg-err:missing-key)
      (182 . gpg-err:too-many)
      (183 . gpg-err:limit-reached)
      (184 . gpg-err:not-initialized)
      (185 . gpg-err:missing-issuer-cert)
      (198 . gpg-err:fully-canceled)
      (199 . gpg-err:unfinished)
      (200 . gpg-err:buffer-too-short)
      (201 . gpg-err:sexp-inv-len-spec)
      (202 . gpg-err:sexp-string-too-long)
      (203 . gpg-err:sexp-unmatched-paren)
      (204 . gpg-err:sexp-not-canonical)
      (205 . gpg-err:sexp-bad-character)
      (206 . gpg-err:sexp-bad-quotation)
      (207 . gpg-err:sexp-zero-prefix)
      (208 . gpg-err:sexp-nested-dh)
      (209 . gpg-err:sexp-unmatched-dh)
      (210 . gpg-err:sexp-unexpected-punc)
      (211 . gpg-err:sexp-bad-hex-char)
      (212 . gpg-err:sexp-odd-hex-numbers)
      (213 . gpg-err:sexp-bad-oct-char)
      (257 . gpg-err:ass-general)
      (258 . gpg-err:ass-accept-failed)
      (259 . gpg-err:ass-connect-failed)
      (260 . gpg-err:ass-inv-response)
      (261 . gpg-err:ass-inv-value)
      (262 . gpg-err:ass-incomplete-line)
      (263 . gpg-err:ass-line-too-long)
      (264 . gpg-err:ass-nested-commands)
      (265 . gpg-err:ass-no-data-cb)
      (266 . gpg-err:ass-no-inquire-cb)
      (267 . gpg-err:ass-not-a-server)
      (268 . gpg-err:ass-not-a-client)
      (269 . gpg-err:ass-server-start)
      (270 . gpg-err:ass-read-error)
      (271 . gpg-err:ass-write-error)
      (273 . gpg-err:ass-too-much-data)
      (274 . gpg-err:ass-unexpected-cmd)
      (275 . gpg-err:ass-unknown-cmd)
      (276 . gpg-err:ass-syntax)
      (277 . gpg-err:ass-canceled)
      (278 . gpg-err:ass-no-input)
      (279 . gpg-err:ass-no-output)
      (280 . gpg-err:ass-parameter)
      (281 . gpg-err:ass-unknown-inquire)
      (1024 . gpg-err:user-1)
      (1025 . gpg-err:user-2)
      (1026 . gpg-err:user-3)
      (1027 . gpg-err:user-4)
      (1028 . gpg-err:user-5)
      (1029 . gpg-err:user-6)
      (1030 . gpg-err:user-7)
      (1031 . gpg-err:user-8)
      (1032 . gpg-err:user-9)
      (1033 . gpg-err:user-10)
      (1034 . gpg-err:user-11)
      (1035 . gpg-err:user-12)
      (1036 . gpg-err:user-13)
      (1037 . gpg-err:user-14)
      (1038 . gpg-err:user-15)
      (1039 . gpg-err:user-16)
      (16381 . gpg-err:missing-errno)
      (16382 . gpg-err:unknown-errno)
      (16383 . gpg-err:eof)

      (,sys-err . gpg-err:system-error)
      (,(logior sys-err 0) . gpg-err:e2big)
      (,(logior sys-err 1) . gpg-err:eacces)
      (,(logior sys-err 2) . gpg-err:eaddrinuse)
      (,(logior sys-err 3) . gpg-err:eaddrnotavail)
      (,(logior sys-err 4) . gpg-err:eadv)
      (,(logior sys-err 5) . gpg-err:eafnosupport)
      (,(logior sys-err 6) . gpg-err:eagain)
      (,(logior sys-err 7) . gpg-err:ealready)
      (,(logior sys-err 8) . gpg-err:eauth)
      (,(logior sys-err 9) . gpg-err:ebackground)
      (,(logior sys-err 10) . gpg-err:ebade)
      (,(logior sys-err 11) . gpg-err:ebadf)
      (,(logior sys-err 12) . gpg-err:ebadfd)
      (,(logior sys-err 13) . gpg-err:ebadmsg)
      (,(logior sys-err 14) . gpg-err:ebadr)
      (,(logior sys-err 15) . gpg-err:ebadrpc)
      (,(logior sys-err 16) . gpg-err:ebadrqc)
      (,(logior sys-err 17) . gpg-err:ebadslt)
      (,(logior sys-err 18) . gpg-err:ebfont)
      (,(logior sys-err 19) . gpg-err:ebusy)
      (,(logior sys-err 20) . gpg-err:ecanceled)
      (,(logior sys-err 21) . gpg-err:echild)
      (,(logior sys-err 22) . gpg-err:echrng)
      (,(logior sys-err 23) . gpg-err:ecomm)
      (,(logior sys-err 24) . gpg-err:econnaborted)
      (,(logior sys-err 25) . gpg-err:econnrefused)
      (,(logior sys-err 26) . gpg-err:econnreset)
      (,(logior sys-err 27) . gpg-err:ed)
      (,(logior sys-err 28) . gpg-err:edeadlk)
      (,(logior sys-err 29) . gpg-err:edeadlock)
      (,(logior sys-err 30) . gpg-err:edestaddrreq)
      (,(logior sys-err 31) . gpg-err:edied)
      (,(logior sys-err 32) . gpg-err:edom)
      (,(logior sys-err 33) . gpg-err:edotdot)
      (,(logior sys-err 34) . gpg-err:edquot)
      (,(logior sys-err 35) . gpg-err:eexist)
      (,(logior sys-err 36) . gpg-err:efault)
      (,(logior sys-err 37) . gpg-err:efbig)
      (,(logior sys-err 38) . gpg-err:eftype)
      (,(logior sys-err 39) . gpg-err:egratuitous)
      (,(logior sys-err 40) . gpg-err:egregious)
      (,(logior sys-err 41) . gpg-err:ehostdown)
      (,(logior sys-err 42) . gpg-err:ehostunreach)
      (,(logior sys-err 43) . gpg-err:eidrm)
      (,(logior sys-err 44) . gpg-err:eieio)
      (,(logior sys-err 45) . gpg-err:eilseq)
      (,(logior sys-err 46) . gpg-err:einprogress)
      (,(logior sys-err 47) . gpg-err:eintr)
      (,(logior sys-err 48) . gpg-err:einval)
      (,(logior sys-err 49) . gpg-err:eio)
      (,(logior sys-err 50) . gpg-err:eisconn)
      (,(logior sys-err 51) . gpg-err:eisdir)
      (,(logior sys-err 52) . gpg-err:eisnam)
      (,(logior sys-err 53) . gpg-err:el2hlt)
      (,(logior sys-err 54) . gpg-err:el2nsync)
      (,(logior sys-err 55) . gpg-err:el3hlt)
      (,(logior sys-err 56) . gpg-err:el3rst)
      (,(logior sys-err 57) . gpg-err:elibacc)
      (,(logior sys-err 58) . gpg-err:elibbad)
      (,(logior sys-err 59) . gpg-err:elibexec)
      (,(logior sys-err 60) . gpg-err:elibmax)
      (,(logior sys-err 61) . gpg-err:elibscn)
      (,(logior sys-err 62) . gpg-err:elnrng)
      (,(logior sys-err 63) . gpg-err:eloop)
      (,(logior sys-err 64) . gpg-err:emediumtype)
      (,(logior sys-err 65) . gpg-err:emfile)
      (,(logior sys-err 66) . gpg-err:emlink)
      (,(logior sys-err 67) . gpg-err:emsgsize)
      (,(logior sys-err 68) . gpg-err:emultihop)
      (,(logior sys-err 69) . gpg-err:enametoolong)
      (,(logior sys-err 70) . gpg-err:enavail)
      (,(logior sys-err 71) . gpg-err:eneedauth)
      (,(logior sys-err 72) . gpg-err:enetdown)
      (,(logior sys-err 73) . gpg-err:enetreset)
      (,(logior sys-err 74) . gpg-err:enetunreach)
      (,(logior sys-err 75) . gpg-err:enfile)
      (,(logior sys-err 76) . gpg-err:enoano)
      (,(logior sys-err 77) . gpg-err:enobufs)
      (,(logior sys-err 78) . gpg-err:enocsi)
      (,(logior sys-err 79) . gpg-err:enodata)
      (,(logior sys-err 80) . gpg-err:enodev)
      (,(logior sys-err 81) . gpg-err:enoent)
      (,(logior sys-err 82) . gpg-err:enoexec)
      (,(logior sys-err 83) . gpg-err:enolck)
      (,(logior sys-err 84) . gpg-err:enolink)
      (,(logior sys-err 85) . gpg-err:enomedium)
      (,(logior sys-err 86) . gpg-err:enomem)
      (,(logior sys-err 87) . gpg-err:enomsg)
      (,(logior sys-err 88) . gpg-err:enonet)
      (,(logior sys-err 89) . gpg-err:enopkg)
      (,(logior sys-err 90) . gpg-err:enoprotoopt)
      (,(logior sys-err 91) . gpg-err:enospc)
      (,(logior sys-err 92) . gpg-err:enosr)
      (,(logior sys-err 93) . gpg-err:enostr)
      (,(logior sys-err 94) . gpg-err:enosys)
      (,(logior sys-err 95) . gpg-err:enotblk)
      (,(logior sys-err 96) . gpg-err:enotconn)
      (,(logior sys-err 97) . gpg-err:enotdir)
      (,(logior sys-err 98) . gpg-err:enotempty)
      (,(logior sys-err 99) . gpg-err:enotnam)
      (,(logior sys-err 100) . gpg-err:enotsock)
      (,(logior sys-err 101) . gpg-err:enotsup)
      (,(logior sys-err 102) . gpg-err:enotty)
      (,(logior sys-err 103) . gpg-err:enotuniq)
      (,(logior sys-err 104) . gpg-err:enxio)
      (,(logior sys-err 105) . gpg-err:eopnotsupp)
      (,(logior sys-err 106) . gpg-err:eoverflow)
      (,(logior sys-err 107) . gpg-err:eperm)
      (,(logior sys-err 108) . gpg-err:epfnosupport)
      (,(logior sys-err 109) . gpg-err:epipe)
      (,(logior sys-err 110) . gpg-err:eproclim)
      (,(logior sys-err 111) . gpg-err:eprocunavail)
      (,(logior sys-err 112) . gpg-err:eprogmismatch)
      (,(logior sys-err 113) . gpg-err:eprogunavail)
      (,(logior sys-err 114) . gpg-err:eproto)
      (,(logior sys-err 115) . gpg-err:eprotonosupport)
      (,(logior sys-err 116) . gpg-err:eprototype)
      (,(logior sys-err 117) . gpg-err:erange)
      (,(logior sys-err 118) . gpg-err:eremchg)
      (,(logior sys-err 119) . gpg-err:eremote)
      (,(logior sys-err 120) . gpg-err:eremoteio)
      (,(logior sys-err 121) . gpg-err:erestart)
      (,(logior sys-err 122) . gpg-err:erofs)
      (,(logior sys-err 123) . gpg-err:erpcmismatch)
      (,(logior sys-err 124) . gpg-err:eshutdown)
      (,(logior sys-err 125) . gpg-err:esocktnosupport)
      (,(logior sys-err 126) . gpg-err:espipe)
      (,(logior sys-err 127) . gpg-err:esrch)
      (,(logior sys-err 128) . gpg-err:esrmnt)
      (,(logior sys-err 129) . gpg-err:estale)
      (,(logior sys-err 130) . gpg-err:estrpipe)
      (,(logior sys-err 131) . gpg-err:etime)
      (,(logior sys-err 132) . gpg-err:etimedout)
      (,(logior sys-err 133) . gpg-err:etoomanyrefs)
      (,(logior sys-err 134) . gpg-err:etxtbsy)
      (,(logior sys-err 135) . gpg-err:euclean)
      (,(logior sys-err 136) . gpg-err:eunatch)
      (,(logior sys-err 137) . gpg-err:eusers)
      (,(logior sys-err 138) . gpg-err:ewouldblock)
      (,(logior sys-err 139) . gpg-err:exdev)
      (,(logior sys-err 140) . gpg-err:exfull)
      
      ;; (65536 . gpg-err:code-dim)
      ;; This is supposed to represent the last possible code + 1, but
      ;; it messes up our gathering of the error code reason strings.
      )))

(define *gpg-err:code-dim* 65536)
;; Error codes are just integers, but they are implemented in a
;; architecture-dependent way.  This variable is equal to (expt 2 16),
;; which is 1+ the highest allowable error code.  We will modulo all
;; error codes by this number, giving us the _real_ error.

(define *gpg:error-codes->errors*
  (alist->vhash *error-code-alist* hashq))

(define *gpg:errors->error-codes*
  (alist->vhash
   (map (lambda (lst)
	  (cons (cdr lst) (car lst)))
	*error-code-alist*)
   hashq))

;; gathering error descriptions from the program "gpg-error"

;; start helpers:
;; The regular expressions used in finding the cruft in the output

(define prefix-rx (make-regexp "^[[:digit:]]+.*[A-Z], "))
(define colonize-rx
  ;; get it?  ``colon---ize'' (^_^) (-_-')
  (make-regexp "(ERR)[_-]"))
(define hyphenize-rx
  (make-regexp "_"))
(define error/string-gap-rx
  (make-regexp "\\) =.*\\w, "))
(define trailing-paren-rx
  (make-regexp "\\)$"))

(define (error-string->pair str)
  ;; This will be a cascade of regexp match-and-replace ops
  (call-with-values
      (lambda ()
	(let* ((str-w\o-prefix
		(match:suffix (regexp-exec prefix-rx str)))
	       (gap-match
		(regexp-exec error/string-gap-rx str-w\o-prefix))
	       (err-name
		(match:prefix gap-match))
	       (err-str
		(match:suffix gap-match)))
	  (values
	   ;; first create the error symbol
	   (string->symbol
	    (string-downcase
	     (regexp-substitute/global
	      #f hyphenize-rx
	      (regexp-substitute #f (regexp-exec
				     colonize-rx
				     err-name)
				 'pre 1 ":" 'post)
	      'pre "-" 'post)))

	   ;; Now isolate and return the explanatory string
	   (match:prefix
	    (regexp-exec
	     trailing-paren-rx err-str)))))
    cons))


(define (create-error-code-alist)
  (let* ((output 
	  (open-input-pipe
	   (string-append
	    "gpg-error"
	    (fold (lambda (n s)
		    (string-append
		     " "
		     (number->string n)
		     s))
		  ""
		  (map (lambda (p)
			 (car p))
		       *error-code-alist*)))))
	 (code-strings
	  (let loop ((s (read-line output))
		     (lst '()))
	    (if (eof-object? s) lst
		(loop (read-line output)
		      (cons s lst))))))
    (close-pipe output)
    (map error-string->pair code-strings)))
;; :end helpers

(define *gpg:error-descriptions*
  (alist->vhash
   (create-error-code-alist)))

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Public interface ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(define (gpg:error-code->error errno)
  "\
Translate the numeric error code @var{errno} to its corresponding
error symbol."
  (cdr (vhash-assq (modulo errno *gpg-err:code-dim*)
		   *gpg:error-codes->errors*)))

(define (gpg:error->error-code err)
  "\
Translate the error symbol @var{err} to its corresponding numeric
error code."
  (cdr (vhash-assq err *gpg:errors->error-codes*)))

(define (gpg:describe-error err)
  "\
Return a string describing the error symbol @var{err}."
  (vhash-assq err *gpg:error-descriptions*))
;;; gpg-err-codes.scm ends here