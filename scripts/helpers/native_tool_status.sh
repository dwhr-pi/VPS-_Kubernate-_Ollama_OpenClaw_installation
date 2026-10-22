#!/usr/bin/env bash
# Menu registration describes prepared sources/builds, not service readiness.
NATIVE_TOOL_STATUS_KEYS=(OpenMontage Wan21 Windmill DeepFilterNet MOSS_TTS Embedded_Debug_HIL
    ChatTTS AudioLDM2 AudioGen Moshi YuE ACE_Step_15 WhisperX Aegisub Basic_Pitch
    Sfizz AIDA_X Kiwi_Edit VOID_Model Just_Dub_It Stable_Audio_Open ProPainter Black Mypy SQLFluff Bats_Core Invoke_Build Gopls Delve GolangCI_Lint Kubeconform KubeLinter TFLint Terraform_Docs
    Alexandria_Audiobook Qwen3_TTS Claude_Code Gemini_CLI Find_Skills REA HF_Accelerate DeepSpeed Hyperfine Colibri Anthropic_CLI YouTube_Agent_Skill)

native_tool_marker() {
    local marker
    case "$1" in
        OpenMontage) marker=openmontage/core-ready.json ;;
        Wan21) marker=wan21/source-ready ;;
        Windmill) marker=windmill/source-ready ;;
        DeepFilterNet) marker=deepfilternet/source-built ;;
        MOSS_TTS) marker=moss_tts/source-built ;;
        Embedded_Debug_HIL) marker=embedded_debug_hil/source-built ;;
        ChatTTS) marker=chattts/source-built ;;
        AudioLDM2) marker=audioldm2/source-built ;;
        AudioGen) marker=audiogen/source-built ;;
        Moshi) marker=moshi/source-built ;;
        YuE) marker=yue/source-ready ;;
        ACE_Step_15) marker=ace_step_15/source-built ;;
        WhisperX) marker=whisperx/source-built ;;
        Aegisub) marker=aegisub/source-ready ;;
        Basic_Pitch) marker=basic_pitch/source-built ;;
        Sfizz) marker=sfizz/source-ready ;;
        AIDA_X) marker=aida_x/source-ready ;;
        Kiwi_Edit) marker=kiwi_edit/source-built ;;
        VOID_Model) marker=void_model/source-ready ;;
        Just_Dub_It) marker=just_dub_it/source-built ;;
        Stable_Audio_Open) marker=stable_audio_open/source-built ;;
        ProPainter) marker=propainter/source-ready ;;
        Alexandria_Audiobook) marker=alexandria_audiobook/source-ready ;;
        Qwen3_TTS) marker=qwen3_tts/source-built ;;
        Claude_Code) marker=claude_code/source-ready.json ;;
        Anthropic_CLI) marker=anthropic_cli/build-ready.json ;;
        Gemini_CLI) marker=gemini_cli/source-ready.json ;;
        Find_Skills) marker=find_skills/source-ready.json ;;
        YouTube_Agent_Skill) marker=youtube_agent_skill/skills-ready.json ;;
        Black) marker=black/build-ready.json ;;
        Mypy) marker=mypy/build-ready.json ;;
        SQLFluff) marker=sqlfluff/build-ready.json ;;
        Bats_Core) marker=bats_core/scripts-ready.json ;;
        Invoke_Build) marker=invoke_build/scripts-ready.json ;;
        Gopls) marker=gopls/build-ready.json ;;
        Delve) marker=delve/build-ready.json ;;
        GolangCI_Lint) marker=golangci_lint/build-ready.json ;;
        Kubeconform) marker=kubeconform/build-ready.json ;;
        KubeLinter) marker=kubelinter/build-ready.json ;;
        TFLint) marker=tflint/build-ready.json ;;
        Terraform_Docs) marker=terraform_docs/build-ready.json ;;
        REA) marker=rea/source-ready.json ;;
        HF_Accelerate) marker=hf_accelerate/source-ready.json ;;
        DeepSpeed) marker=deepspeed/source-ready.json ;;
        Hyperfine) marker=hyperfine/source-ready.json ;;
        Colibri) marker=colibri/source-ready.json ;;
        *) return 2 ;;
    esac
    NATIVE_TOOL_MARKER="$marker"
    printf '%s\n' "$marker"
}

native_tool_sync_selected() {
    local root="$1" tool marker file tmp entry key
    shift
    local -a selected=("$@")
    local -A managed=() present=()
    [[ "$root" == /* && "$root" != / && ! -L "$root" && ! -L "$root/status" ]] || return 1
    for tool in "${selected[@]}"; do
        native_tool_marker "$tool" >/dev/null || return 2
        managed["$tool"]=1
        marker="$root/tools/$NATIVE_TOOL_MARKER"
        if [[ -f "$marker" && ! -L "$marker" && -s "$marker" && ! -L "$root/tools" && ! -L "${marker%/*}" ]]; then
            if [[ "$tool" == Anthropic_CLI ]]; then
                if [[ -L "$root/tools/anthropic_cli/bin" ]]; then continue; fi
                if [[ ! -f "$root/tools/anthropic_cli/bin/ant" || -L "$root/tools/anthropic_cli/bin/ant" || ! -s "$root/tools/anthropic_cli/bin/ant" ]]; then
                    if [[ ! -f "$root/tools/anthropic_cli/bin/ant.exe" || -L "$root/tools/anthropic_cli/bin/ant.exe" || ! -s "$root/tools/anthropic_cli/bin/ant.exe" ]]; then continue; fi
                fi
            fi
            present["$tool"]=1
            if [[ "$tool" == OpenMontage ]]; then
                if [[ -L "$root/tools/openmontage/venv" || ! -d "$root/tools/openmontage/venv" ]] ||
                   [[ ! -f "$root/tools/openmontage/venv/bin/python" && ! -f "$root/tools/openmontage/venv/Scripts/python.exe" ]]; then
                    unset 'present[$tool]'
                fi
            fi
        fi
    done
    # One pass per status file, rather than rewriting both for every tool.
    mkdir -p "$root/status" || return 1
    for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
        [[ ! -L "$file" ]] || return 1
        tmp="$(mktemp "${file}.XXXXXX")" || return 1
        if [[ -f "$file" ]]; then
            while IFS= read -r entry || [[ -n "$entry" ]]; do
                key="${entry%$'\r'}"
                key="${key//\"/}"
                if [[ -z "$key" ]] || [[ -z "${managed[$key]:-}" ]]; then
                    printf '%s\n' "$entry" >> "$tmp"
                fi
            done < "$file"
        fi
        for tool in "${selected[@]}"; do
            if [[ "${present[$tool]:-}" == 1 ]]; then printf '%s\n' "$tool" >> "$tmp"; fi
        done
        if [[ -f "$file" ]] && cmp -s "$tmp" "$file"; then
            rm -f -- "$tmp"
        else
            mv -- "$tmp" "$file" || return 1
        fi
    done
}

native_tool_sync_all() {
    native_tool_sync_selected "$1" "${NATIVE_TOOL_STATUS_KEYS[@]}"
}

native_tool_sync_status() {
    native_tool_sync_selected "$2" "$1"
}
