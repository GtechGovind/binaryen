;; RUN: wasm-opt %s --all-features --remove-unused-module-elements -S -o - | filecheck %s --check-prefix=DEFAULT
;; RUN: wasm-opt %s --all-features --remove-empty-function-exports -S -o - | filecheck %s --check-prefix=REMOVE
;; RUN: wasm-opt %s --all-features --remove-empty-function-exports --remove-empty-function-exports -S -o - | filecheck %s --check-prefix=REMOVE
;; RUN: wasm-opt %s --all-features --remove-empty-function-exports --remove-unused-module-elements -S -o - | filecheck %s --check-prefix=DCE

(module
  (import "env" "noop" (func $imported))

  (func $empty)
  (func $empty-block (block))
  (func $empty-param (param i32) (nop))
  (func $empty-used)
  (func $call-empty
    (call $empty-used)
  )
  (func $nonempty
    (drop
      (i32.const 0)
    )
  )
  (func $returns (return))

  (memory $memory 1)
  (table $table 1 funcref)
  (global $global i32 (i32.const 0))
  (tag $tag)
  (start $nonempty)

  (export "empty" (func $empty))
  (export "empty-alias" (func $empty))
  (export "empty-block" (func $empty-block))
  (export "empty-param" (func $empty-param))
  (export "empty-used" (func $empty-used))
  (export "call-empty" (func $call-empty))
  (export "nonempty" (func $nonempty))
  (export "imported" (func $imported))
  (export "returns" (func $returns))
  (export "memory" (memory $memory))
  (export "table" (table $table))
  (export "global" (global $global))
  (export "tag" (tag $tag))
)

;; DEFAULT:      (export "empty" (func $empty))
;; DEFAULT-NEXT: (export "empty-alias" (func $empty))
;; DEFAULT-NEXT: (export "empty-block" (func $empty-block))
;; DEFAULT-NEXT: (export "empty-param" (func $empty-param))
;; DEFAULT-NEXT: (export "empty-used" (func $empty-used))
;; DEFAULT:      (func $empty (type
;; DEFAULT:      (func $empty-used

;; REMOVE-NOT:   (export "empty
;; REMOVE:       (export "call-empty" (func $call-empty))
;; REMOVE-NEXT:  (export "nonempty" (func $nonempty))
;; REMOVE-NEXT:  (export "imported" (func $imported))
;; REMOVE-NEXT:  (export "returns" (func $returns))
;; REMOVE-NEXT:  (export "memory" (memory $memory))
;; REMOVE-NEXT:  (export "table" (table $table))
;; REMOVE-NEXT:  (export "global" (global $global))
;; REMOVE-NEXT:  (export "tag" (tag $tag))
;; REMOVE-NOT:   (export
;; REMOVE:       (start $nonempty)
;; REMOVE:       (func $empty (type
;; REMOVE:       (func $empty-block
;; REMOVE:       (func $empty-param
;; REMOVE:       (func $empty-used

;; DCE-NOT:      (export "empty
;; DCE:          (export "call-empty" (func $call-empty))
;; DCE-NEXT:     (export "nonempty" (func $nonempty))
;; DCE-NEXT:     (export "imported" (func $imported))
;; DCE-NEXT:     (export "returns" (func $returns))
;; DCE-NEXT:     (export "memory" (memory $memory))
;; DCE-NEXT:     (export "table" (table $table))
;; DCE-NEXT:     (export "global" (global $global))
;; DCE-NEXT:     (export "tag" (tag $tag))
;; DCE:          (start $nonempty)
;; DCE-NOT:      (func $empty (type
;; DCE-NOT:      (func $empty-block
;; DCE-NOT:      (func $empty-param
;; DCE:          (func $empty-used
