package com.mottu.rastreamento.controller.view;

import com.mottu.rastreamento.dto.AlocacaoDTO;
import com.mottu.rastreamento.models.Alocacao;
import com.mottu.rastreamento.service.AlocacaoService;
import com.mottu.rastreamento.service.MotoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/alocacoes")
@RequiredArgsConstructor
public class AlocacaoViewController {

    private final AlocacaoService alocacaoService;
    private final MotoService motoService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("alocacoes", alocacaoService.listarTodas());
        return "alocacoes/list";
    }

    @GetMapping("/nova")
    public String novaForm(Model model) {
        model.addAttribute("alocacao", new AlocacaoDTO());
        model.addAttribute("motos", motoService.listarTodasDisponiveis());
        return "alocacoes/form";
    }

    @PostMapping
    public String abrir(@Valid @ModelAttribute("alocacao") AlocacaoDTO dto) {
        alocacaoService.abrirAlocacao(dto);
        return "redirect:/alocacoes";
    }

    @GetMapping("/encerrar/{id}")
    public String encerrar(@PathVariable Long id) {
        alocacaoService.encerrarAlocacao(id);
        return "redirect:/alocacoes";
    }
}

