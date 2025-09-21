package com.mottu.rastreamento.controller.view;

import com.mottu.rastreamento.dto.ManutencaoDTO;
import com.mottu.rastreamento.service.ManutencaoService;
import com.mottu.rastreamento.service.MotoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/manutencoes")
@RequiredArgsConstructor
public class ManutencaoViewController {

    private final ManutencaoService manutencaoService;
    private final MotoService motoService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("manutencoes", manutencaoService.listarTodas());
        return "manutencoes/list";
    }

    @GetMapping("/nova")
    public String novaForm(Model model) {
        model.addAttribute("manutencao", new ManutencaoDTO());
        model.addAttribute("motos", motoService.listarTodas());
        return "manutencoes/form";
    }

    @PostMapping
    public String abrir(@Valid @ModelAttribute("manutencao") ManutencaoDTO dto) {
        manutencaoService.abrirManutencao(dto);
        return "redirect:/manutencoes";
    }

    @GetMapping("/encerrar/{id}")
    public String encerrar(@PathVariable Long id) {
        manutencaoService.encerrarManutencao(id);
        return "redirect:/manutencoes";
    }
}
