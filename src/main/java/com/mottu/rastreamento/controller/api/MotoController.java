package com.mottu.rastreamento.controller.api;

import com.mottu.rastreamento.dto.MotoDTO;
import com.mottu.rastreamento.service.MotoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/motos")
@RequiredArgsConstructor
public class MotoController {

    private final MotoService service;

    @PostMapping
    public ResponseEntity<MotoDTO> criar(@Valid @RequestBody MotoDTO dto) {
        return ResponseEntity.ok(service.salvar(dto));
    }

    @GetMapping
    public ResponseEntity<Page<MotoDTO>> listar(
            @PageableDefault(size = 10, sort = "modelo") Pageable pageable) {
        return ResponseEntity.ok(service.listar(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<MotoDTO> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(service.buscarPorId(id));
    }

    @GetMapping("/buscar/uwb")
    public ResponseEntity<MotoDTO> buscarPorUWB(@RequestParam String identificadorUWB) {
        return ResponseEntity.ok(service.buscarPorIdentificadorUWB(identificadorUWB));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MotoDTO> atualizar(@PathVariable Long id, @Valid @RequestBody MotoDTO dto) {
        return ResponseEntity.ok(service.atualizar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
