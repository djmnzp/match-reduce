#define ATS_DYNLOADFLAG 0

staload "./pattern.sats"
staload "./rule.sats"
staload "./skeleton.sats"
staload "./string.sats"

#include "share/atspre_staload.hats"

implement rule_is_valid(rule): bool =
	let
		fun loop(ske: !Skeleton, pat: !Pattern): bool =
			case+ ske of
			| list_vt_nil() => true
			| list_vt_cons(ske_symbol(_), ss) => loop(ss, pat)
			| list_vt_cons(ske_hole(s), ss) => loop2(s, pat) && loop(ss, pat) // not tail recursive
		and
		loop2(s: !String, pat: !Pattern): bool =
			case+ pat of
			| list_vt_nil() => false
			| list_vt_cons(pat_symbol(_), ps) => loop2(s, ps)
			| list_vt_cons(pat_atom(p), ps) => if compare(s, p) = 0 then true else loop2(s, ps)
			| list_vt_cons(pat_mult(p), ps) => if compare(s, p) = 0 then true else loop2(s, ps)
			| list_vt_cons(pat_bal(p), ps) => if compare(s, p) = 0 then true else loop2(s, ps)
			| list_vt_cons(pat_under(), ps) => loop2(s, ps)
			| list_vt_cons(pat_ellip(), ps) => loop2(s, ps)
	in
		loop(rule.skeleton, rule.pattern) && length(rule.pattern) > 0
	end

implement rule_copy(r) =
	let
		val n = strnptr_copy(r.name)
		val () = assertloc(strnptr_isnot_null(n))
	in
		@{
			level = r.level,
			precedence = r.precedence,
			name = n,
			pattern = pattern_copy(r.pattern),
			skeleton = skeleton_copy(r.skeleton)
		}
	end

implement rule_print(r) = (
	print!(r.level, " ", r.precedence, " ", r.name, " : ");
	pattern_print(r.pattern);
	print("=> ");
	skeleton_print(r.skeleton);
)

implement rule_free(r) =
	let
		val+ @{level = l, precedence = p, name = n, pattern = pt, skeleton = sk} = r
	in
		strnptr_free(n);
		pattern_free(pt);
		skeleton_free(sk)
	end