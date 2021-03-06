(*
 * Copyright (c) 2014 Magnus Skjegstad <magnus@skjegstad.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Just-In-Time Summoning of Unikernels.

    Jitsu is a forwarding DNS server that automatically starts
    unikernel VMs when their domain is requested.  The DNS response is
    sent to the client after the unikernel has started, enabling the
    client to use unmodified software to communicate with unikernels
    that are started on demand. If no DNS requests are received for
    the unikernel within a given timeout period, the VM is
    automatically stopped. *)


type vm_stop_mode = VmStopDestroy | VmStopSuspend | VmStopShutdown

type t
(** The type of Jitsu states. *)

val create: (string -> unit) -> string -> Dns_resolver_unix.t option -> ?vm_count:int -> ?use_synjitsu:(string option) -> unit -> t
(** [create log_function name resolver vm_count use_synjitsu] creates a new Jitsu instance, 
    where vm_count is the initial size of the hash table and use_synjitsu is the optional 
    name or uuid of a synjitsu unikernel. *)

val process: t -> Dns.Packet.t Dns_server.process
(** Process function for ocaml-dns. Starts new VMs from DNS queries or
    forwards request to a fallback resolver *)

val add_vm: t -> domain:string -> name:string -> Ipaddr.V4.t -> vm_stop_mode ->
  delay:float -> ttl:int -> unit Lwt.t
(** [add_vm t domain name ip stop_mode delay ttl] adds a VM to be
    monitored by jitsu.  FIXME. *)

val stop_expired_vms: t -> unit
(** Iterate through the internal VM table and stop VMs that haven't
    received requests for more than [ttl*2] seconds. *)
