defmodule CyaneaWeb.ScienceComponents do
  @moduledoc """
  Domain-specific bioinformatics components for the Cyanea platform.

  These components handle scientific artifacts, QC indicators, sequence display,
  and metric dashboards used across research-oriented views.
  """
  use Phoenix.Component

  import CyaneaWeb.UIComponents

  # ---------------------------------------------------------------------------
  # artifact_card
  # ---------------------------------------------------------------------------

  @doc """
  Renders a card for a scientific artifact (dataset, protocol, notebook, etc.).

  Composes card, visibility_badge, badge, and metadata_row components.

  ## Examples

      <.artifact_card
        name="Human Genome Assembly"
        type={:dataset}
        description="GRCh38 reference genome"
        owner_name="cyanea-lab"
        owner_path={~p"/cyanea-lab"}
        path={~p"/cyanea-lab/grch38"}
        tags={["genomics", "reference"]}
      />
  """
  attr :name, :string, required: true

  attr :type, :atom,
    required: true,
    values: ~w(dataset protocol notebook pipeline result)a

  attr :description, :string, default: nil
  attr :visibility, :string, default: "public"
  attr :owner_name, :string, required: true
  attr :owner_path, :string, required: true
  attr :path, :string, required: true
  attr :stars_count, :integer, default: 0
  attr :license, :string, default: nil
  attr :tags, :list, default: []
  attr :updated_at, :any, default: nil
  attr :class, :string, default: nil

  def artifact_card(assigns) do
    ~H"""
    <.link navigate={@path} class={["block group", @class]}>
      <.card class="transition hover:border-slate-300 dark:hover:border-slate-600">
        <div class="flex items-start justify-between gap-3">
          <div class="flex items-center gap-2 min-w-0">
            <.icon
              name={artifact_type_icon(@type)}
              class="h-5 w-5 shrink-0 text-slate-400"
            />
            <div class="min-w-0">
              <div class="flex items-center gap-2">
                <span class="text-sm text-slate-500 dark:text-slate-400">
                  <%= @owner_name %>
                </span>
                <span class="text-slate-300 dark:text-slate-600">/</span>
                <span class="truncate font-semibold text-slate-900 group-hover:text-primary dark:text-white">
                  <%= @name %>
                </span>
              </div>
            </div>
          </div>
          <.visibility_badge visibility={@visibility} />
        </div>

        <p :if={@description} class="mt-2 text-sm text-slate-600 line-clamp-2 dark:text-slate-400">
          <%= @description %>
        </p>

        <div :if={@tags != []} class="mt-3 flex flex-wrap gap-1.5">
          <.badge :for={tag <- Enum.take(@tags, 5)} color={:primary} size={:xs}>
            <%= tag %>
          </.badge>
        </div>

        <div class="mt-4 flex flex-wrap items-center gap-4">
          <.metadata_row :if={@license} icon="hero-scale">
            <%= CyaneaWeb.Formatters.license_display(@license) %>
          </.metadata_row>
          <.metadata_row :if={@updated_at} icon="hero-clock">
            Updated <%= CyaneaWeb.Formatters.format_relative(@updated_at) %>
          </.metadata_row>
          <.metadata_row :if={@stars_count > 0} icon="hero-star">
            <%= @stars_count %>
          </.metadata_row>
        </div>
      </.card>
    </.link>
    """
  end

  defp artifact_type_icon(:dataset), do: "hero-circle-stack"
  defp artifact_type_icon(:protocol), do: "hero-document-text"
  defp artifact_type_icon(:notebook), do: "hero-book-open"
  defp artifact_type_icon(:pipeline), do: "hero-play-circle"
  defp artifact_type_icon(:result), do: "hero-chart-bar"

  # ---------------------------------------------------------------------------
  # qc_badge
  # ---------------------------------------------------------------------------

  @doc """
  Renders a quality control status badge with icon.

  ## Examples

      <.qc_badge status={:pass} />
      <.qc_badge status={:fail} label="Coverage check" />
  """
  attr :status, :atom, required: true, values: ~w(pass warn fail pending unknown)a
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  def qc_badge(assigns) do
    {color, icon, default_label} = qc_status_props(assigns.status)
    assigns = assign(assigns, color: color, icon: icon, display_label: assigns.label || default_label)

    ~H"""
    <.badge color={@color} class={@class}>
      <span class="flex items-center gap-1">
        <.icon name={@icon} class="h-3 w-3" />
        <%= @display_label %>
      </span>
    </.badge>
    """
  end

  defp qc_status_props(:pass), do: {:success, "hero-check-circle-mini", "Pass"}
  defp qc_status_props(:warn), do: {:warning, "hero-exclamation-triangle-mini", "Warning"}
  defp qc_status_props(:fail), do: {:error, "hero-x-circle-mini", "Fail"}
  defp qc_status_props(:pending), do: {:gray, "hero-clock-mini", "Pending"}
  defp qc_status_props(:unknown), do: {:gray, "hero-question-mark-circle-mini", "Unknown"}

  # ---------------------------------------------------------------------------
  # sequence_display
  # ---------------------------------------------------------------------------

  @doc """
  Renders a formatted sequence display (DNA, RNA, protein).

  ## Examples

      <.sequence_display sequence="ATCGATCGATCG" />
      <.sequence_display sequence={@fasta_content} format={:fasta} show_line_numbers />
  """
  attr :sequence, :string, required: true
  attr :format, :atom, default: :plain, values: ~w(plain fasta)a
  attr :show_line_numbers, :boolean, default: true
  attr :max_length, :integer, default: 10_000
  attr :class, :string, default: nil

  def sequence_display(assigns) do
    {display_seq, truncated} = prepare_sequence(assigns.sequence, assigns.max_length)
    lines = wrap_sequence(display_seq, 80)

    assigns =
      assigns
      |> assign(:lines, lines)
      |> assign(:truncated, truncated)
      |> assign(:total_length, String.length(assigns.sequence))

    ~H"""
    <div class={[
      "overflow-x-auto rounded-lg border border-slate-200 bg-slate-50 dark:border-slate-700 dark:bg-slate-900",
      @class
    ]}>
      <div :if={@format == :fasta} class="border-b border-slate-200 px-4 py-2 dark:border-slate-700">
        <span class="text-xs font-medium text-slate-500">FASTA</span>
      </div>
      <div class="p-4 overflow-x-auto">
        <table class="font-mono text-sm leading-relaxed text-slate-800 dark:text-slate-200">
          <tr :for={{line, idx} <- Enum.with_index(@lines, 1)}>
            <td
              :if={@show_line_numbers}
              class="select-none pr-4 text-right align-top text-slate-400"
            >
              <%= idx %>
            </td>
            <td class="whitespace-pre"><%= line %></td>
          </tr>
        </table>
      </div>
      <div
        :if={@truncated}
        class="border-t border-slate-200 px-4 py-2 text-center text-xs text-slate-500 dark:border-slate-700"
      >
        Showing first <%= @max_length %> of <%= @total_length %> characters
      </div>
    </div>
    """
  end

  defp prepare_sequence(seq, max_length) when byte_size(seq) > max_length do
    {String.slice(seq, 0, max_length), true}
  end

  defp prepare_sequence(seq, _max_length), do: {seq, false}

  defp wrap_sequence(seq, width) do
    seq
    |> String.replace(~r/\r?\n/, "")
    |> String.graphemes()
    |> Enum.chunk_every(width)
    |> Enum.map(&Enum.join/1)
  end

  # ---------------------------------------------------------------------------
  # metric_card
  # ---------------------------------------------------------------------------

  @doc """
  Renders a metric card for dashboard KPIs.

  ## Examples

      <.metric_card label="Samples" value={1_234} icon="hero-beaker" />
      <.metric_card label="QC Pass Rate" value="98.5%" change={2.3} change_label="vs last week" />
  """
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :change, :float, default: nil
  attr :change_label, :string, default: nil
  attr :icon, :string, default: nil
  attr :class, :string, default: nil

  def metric_card(assigns) do
    ~H"""
    <.card class={@class}>
      <div class="flex items-start justify-between">
        <div>
          <p class="text-sm font-medium text-slate-500 dark:text-slate-400"><%= @label %></p>
          <p class="mt-1 text-3xl font-bold font-display tracking-tight text-slate-900 dark:text-white">
            <%= @value %>
          </p>
          <div :if={@change} class="mt-1 flex items-center gap-1 text-sm">
            <%= if @change > 0 do %>
              <.icon name="hero-arrow-trending-up-mini" class="h-4 w-4 text-emerald-500" />
              <span class="text-emerald-600 dark:text-emerald-400">+<%= Float.round(@change, 1) %>%</span>
            <% else %>
              <.icon name="hero-arrow-trending-down-mini" class="h-4 w-4 text-red-500" />
              <span class="text-red-600 dark:text-red-400"><%= Float.round(@change, 1) %>%</span>
            <% end %>
            <span :if={@change_label} class="text-slate-500 dark:text-slate-400">
              <%= @change_label %>
            </span>
          </div>
        </div>
        <div
          :if={@icon}
          class="rounded-lg bg-primary-50 p-2 dark:bg-primary-900/20"
        >
          <.icon name={@icon} class="h-6 w-6 text-primary-500" />
        </div>
      </div>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # sequence_viewer
  # ---------------------------------------------------------------------------

  @doc """
  Renders an interactive WASM-powered sequence viewer.

  Uses the `SequenceViewer` LiveView hook to color-code nucleotides,
  compute GC%, and provide analysis actions (reverse complement, translate).

  ## Examples

      <.sequence_viewer id="seq-1" sequence="ATCGATCGATCG" />
      <.sequence_viewer id="seq-2" sequence={@fasta_content} label="Gene X" />
  """
  attr :id, :string, required: true
  attr :sequence, :string, required: true
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  def sequence_viewer(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="SequenceViewer"
      data-sequence={@sequence}
      data-label={@label}
      class={@class}
    >
      <div class="animate-pulse rounded-lg border border-slate-200 dark:border-slate-700 p-6">
        <div class="space-y-3">
          <div class="flex gap-4">
            <div class="h-4 w-16 rounded bg-slate-200 dark:bg-slate-700"></div>
            <div class="h-4 w-20 rounded bg-slate-200 dark:bg-slate-700"></div>
            <div class="h-4 w-12 rounded bg-slate-200 dark:bg-slate-700"></div>
          </div>
          <div class="h-4 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
          <div class="h-4 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
          <div class="h-4 w-3/4 rounded bg-slate-200 dark:bg-slate-700"></div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # alignment_viewer
  # ---------------------------------------------------------------------------

  @doc """
  Renders an interactive WASM-powered alignment viewer.

  Can run alignments client-side via WASM or display pre-computed results.

  ## Examples

      <.alignment_viewer id="aln-1" query="ACGT" target="ACGGT" />
      <.alignment_viewer id="aln-2" result={@alignment_result} />
  """
  attr :id, :string, required: true
  attr :query, :string, default: nil
  attr :target, :string, default: nil
  attr :mode, :string, default: "global"
  attr :result, :map, default: nil
  attr :class, :string, default: nil

  def alignment_viewer(assigns) do
    result_json = if assigns.result, do: Jason.encode!(assigns.result), else: nil
    assigns = assign(assigns, :result_json, result_json)

    ~H"""
    <div
      id={@id}
      phx-hook="AlignmentViewer"
      data-query={@query}
      data-target={@target}
      data-mode={@mode}
      data-result={@result_json}
      class={@class}
    >
      <div class="animate-pulse rounded-lg border border-slate-200 dark:border-slate-700 p-6">
        <div class="space-y-3">
          <div class="flex gap-4">
            <div class="h-4 w-14 rounded bg-slate-200 dark:bg-slate-700"></div>
            <div class="h-4 w-20 rounded bg-slate-200 dark:bg-slate-700"></div>
          </div>
          <div class="h-4 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
          <div class="h-4 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
          <div class="h-4 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # tree_viewer
  # ---------------------------------------------------------------------------

  @doc """
  Renders an interactive WASM-powered phylogenetic tree viewer.

  Parses Newick format and renders a rectangular phylogram as SVG.

  ## Examples

      <.tree_viewer id="tree-1" newick="((A:0.1,B:0.2):0.3,C:0.4);" />
      <.tree_viewer id="tree-2" newick={@newick_data} width={800} height={600} />
  """
  attr :id, :string, required: true
  attr :newick, :string, required: true
  attr :width, :integer, default: 600
  attr :height, :integer, default: 400
  attr :class, :string, default: nil

  def tree_viewer(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="TreeViewer"
      data-newick={@newick}
      data-width={@width}
      data-height={@height}
      class={@class}
    >
      <div class="animate-pulse rounded-lg border border-slate-200 dark:border-slate-700 p-6">
        <div class="space-y-3">
          <div class="flex gap-4">
            <div class="h-4 w-16 rounded bg-slate-200 dark:bg-slate-700"></div>
            <div class="h-4 w-20 rounded bg-slate-200 dark:bg-slate-700"></div>
          </div>
          <div class="h-32 w-full rounded bg-slate-200 dark:bg-slate-700"></div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private icon helper
  # ---------------------------------------------------------------------------

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
