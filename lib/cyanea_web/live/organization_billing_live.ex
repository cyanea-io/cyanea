defmodule CyaneaWeb.OrganizationBillingLive do
  use CyaneaWeb, :live_view

  alias Cyanea.Billing
  alias Cyanea.Organizations

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    current_user = socket.assigns.current_user
    org = Organizations.get_organization_by_slug(slug)

    cond do
      is_nil(org) ->
        {:ok,
         socket
         |> put_flash(:error, "Organization not found.")
         |> redirect(to: ~p"/dashboard")}

      not authorized?(current_user.id, org.id) ->
        {:ok,
         socket
         |> put_flash(:error, "You must be an owner or admin to manage billing.")
         |> redirect(to: ~p"/#{slug}")}

      true ->
        storage = Billing.storage_info(org)
        member_count = length(Organizations.list_members(org.id))

        {:ok,
         assign(socket,
           page_title: "Billing — #{org.name}",
           org: org,
           storage: storage,
           member_count: member_count
         )}
    end
  end

  @impl true
  def handle_event("checkout", _params, socket) do
    org = socket.assigns.org
    success_url = url(~p"/organizations/#{org.slug}/settings/billing?session_id={CHECKOUT_SESSION_ID}")
    cancel_url = url(~p"/organizations/#{org.slug}/settings/billing")

    case Billing.create_checkout_session(org, success_url, cancel_url) do
      {:ok, session} ->
        {:noreply, redirect(socket, external: session.url)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to start checkout. Please try again.")}
    end
  end

  def handle_event("portal", _params, socket) do
    org = socket.assigns.org
    return_url = url(~p"/organizations/#{org.slug}/settings/billing")

    case Billing.create_portal_session(org, return_url) do
      {:ok, session} ->
        {:noreply, redirect(socket, external: session.url)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to open billing portal. Please try again.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.header>
        Billing — <%= @org.name %>
        <:subtitle>Manage your organization's subscription and storage.</:subtitle>
      </.header>

      <%!-- Plan card --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Current plan</h3>
            <div class="mt-2 flex items-center gap-2">
              <.plan_badge plan={@org.plan} />
              <span :if={@org.plan == "pro"} class="text-sm text-slate-500">
                $499/workspace/month &middot; <%= @member_count %> member(s)
              </span>
            </div>
          </div>
          <div>
            <%= if @org.plan == "free" do %>
              <button
                phx-click="checkout"
                class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white shadow-sm transition hover:bg-primary-700"
              >
                Upgrade to Pro — $499/workspace/mo
              </button>
            <% else %>
              <button
                phx-click="portal"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50 dark:border-slate-600 dark:text-slate-300 dark:hover:bg-slate-700"
              >
                Manage billing
              </button>
            <% end %>
          </div>
        </div>

        <div class="mt-6 grid gap-4 sm:grid-cols-2">
          <div class="rounded-lg border border-slate-100 p-4 dark:border-slate-700">
            <h4 class="text-sm font-medium text-slate-900 dark:text-white">Free</h4>
            <ul class="mt-2 space-y-1 text-sm text-slate-600 dark:text-slate-400">
              <li>2 GB storage</li>
              <li>50 MB max file size</li>
              <li>1 member</li>
              <li>WASM-only compute</li>
              <li>Public spaces only</li>
              <li>Community support</li>
            </ul>
          </div>
          <div class={"rounded-lg border p-4 " <> if(@org.plan == "pro", do: "border-primary bg-primary/5", else: "border-slate-100 dark:border-slate-700")}>
            <h4 class="text-sm font-medium text-slate-900 dark:text-white">
              Pro
              <span :if={@org.plan == "pro"} class="ml-1 text-xs text-primary">Current</span>
            </h4>
            <ul class="mt-2 space-y-1 text-sm text-slate-600 dark:text-slate-400">
              <li>1 TB storage</li>
              <li>200 MB max file size</li>
              <li>5 seats included (+$29/extra)</li>
              <li>10,000 compute credits/mo</li>
              <li>Server-side execution (CPU)</li>
              <li>Public + private spaces</li>
              <li>Audit log export</li>
              <li>Priority support + SLA</li>
            </ul>
          </div>
        </div>
      </div>

      <%!-- Storage --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Storage usage</h3>
        <div class="mt-4">
          <.storage_bar storage={@storage} />
        </div>
      </div>
    </div>
    """
  end

  defp authorized?(user_id, org_id) do
    case Organizations.authorize(user_id, org_id, "admin") do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp plan_badge(assigns) do
    ~H"""
    <span
      :if={@plan == "free"}
      class="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-700 dark:bg-slate-700 dark:text-slate-300"
    >
      Free
    </span>
    <span
      :if={@plan == "pro"}
      class="inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary"
    >
      Pro
    </span>
    """
  end

  defp storage_bar(assigns) do
    color =
      cond do
        assigns.storage.percentage >= 100 -> "bg-red-500"
        assigns.storage.percentage >= 80 -> "bg-amber-500"
        true -> "bg-primary"
      end

    assigns = assign(assigns, :color, color)

    ~H"""
    <div class="flex items-center justify-between text-sm">
      <span class="text-slate-600 dark:text-slate-400">
        <%= format_bytes(@storage.bytes_used) %> of <%= format_bytes(@storage.quota) %> used
      </span>
      <span class="font-medium text-slate-900 dark:text-white"><%= @storage.percentage %>%</span>
    </div>
    <div class="mt-2 h-2 w-full overflow-hidden rounded-full bg-slate-100 dark:bg-slate-700">
      <div class={"h-full rounded-full transition-all " <> @color} style={"width: #{min(@storage.percentage, 100)}%"} />
    </div>
    """
  end

  defp format_bytes(bytes) when bytes < 1_073_741_824 do
    mb = Float.round(bytes / 1_048_576, 1)
    "#{mb} MB"
  end

  defp format_bytes(bytes) do
    gb = Float.round(bytes / 1_073_741_824, 1)
    "#{gb} GB"
  end
end
