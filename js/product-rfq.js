/**
 * Vishnu Balaji Global - Product Landing Page RFQ Form Handler
 * Facilitates multi-channel quotation routing: WhatsApp, Mailto, and Supabase.
 */

document.addEventListener("DOMContentLoaded", function () {
  // Mobile Nav Toggle
  const mobileBtn = document.getElementById("mobileMenuBtn");
  const mainNav = document.getElementById("mainNav");
  if (mobileBtn && mainNav) {
    mobileBtn.addEventListener("click", function () {
      mainNav.classList.toggle("active");
    });
  }

  // FAQ Accordion Toggles
  const faqQuestions = document.querySelectorAll(".faq-question");
  faqQuestions.forEach(function (q) {
    q.addEventListener("click", function () {
      const item = q.parentElement;
      const answer = item.querySelector(".faq-answer");
      const icon = q.querySelector("i");
      if (answer) {
        if (answer.style.display === "none" || !answer.style.display) {
          answer.style.display = "block";
          if (icon) icon.className = "fas fa-chevron-up";
        } else {
          answer.style.display = "none";
          if (icon) icon.className = "fas fa-chevron-down";
        }
      }
    });
  });

  // Dedicated Product RFQ Form Handler
  const rfqForm = document.getElementById("productRfqForm");
  if (rfqForm) {
    rfqForm.addEventListener("submit", function (e) {
      e.preventDefault();

      const btn = rfqForm.querySelector("button[type='submit']");
      const originalText = btn ? btn.textContent : "Submit RFQ";
      if (btn) {
        btn.disabled = true;
        btn.textContent = "Routing Quotation...";
      }

      const formData = new FormData(rfqForm);
      const payload = {
        name: formData.get("name")?.toString().trim() || "",
        company: formData.get("company")?.toString().trim() || "Independent Buyer",
        email: formData.get("email")?.toString().trim() || "",
        country: formData.get("country")?.toString().trim() || "",
        product: formData.get("product")?.toString().trim() || "Agricultural Commodity",
        quantity: formData.get("quantity")?.toString().trim() || "1",
        unit: formData.get("unit")?.toString().trim() || "MT",
        destination_port: formData.get("destination_port")?.toString().trim() || "FOB Origin India",
        message: formData.get("message")?.toString().trim() || "Inquiring about export specifications and container price.",
      };

      // 1. Prepare WhatsApp Message
      const waText = `*Export RFQ - Vishnu Balaji Global*\n` +
        `-----------------------------\n` +
        `*Product:* ${payload.product}\n` +
        `*Buyer:* ${payload.name} (${payload.company})\n` +
        `*Country:* ${payload.country}\n` +
        `*Email:* ${payload.email}\n` +
        `*Quantity:* ${payload.quantity} ${payload.unit}\n` +
        `*Discharge Port:* ${payload.destination_port}\n` +
        `*Requirement:* ${payload.message}\n` +
        `-----------------------------`;
      const waUrl = "https://wa.me/919160666483?text=" + encodeURIComponent(waText);

      // 2. Prepare Email Mailto
      const emailSubj = `New Export Inquiry: ${payload.product} - ${payload.name}`;
      const emailBody = `Vishnu Balaji Global Export Inquiry\n\n` +
        `Product: ${payload.product}\n` +
        `Buyer Name: ${payload.name}\n` +
        `Company: ${payload.company}\n` +
        `Country: ${payload.country}\n` +
        `Business Email: ${payload.email}\n` +
        `Quantity: ${payload.quantity} ${payload.unit}\n` +
        `Destination Port: ${payload.destination_port}\n` +
        `Details: ${payload.message}\n`;
      const mailtoUrl = `mailto:sales@vishnubalajiglobal.com,depu.sep13@gmail.com?subject=${encodeURIComponent(emailSubj)}&body=${encodeURIComponent(emailBody)}`;

      // 3. Background dispatch via FormSubmit API
      const mailData = new FormData();
      mailData.append("Product", payload.product);
      mailData.append("Buyer Name", payload.name);
      mailData.append("Company", payload.company);
      mailData.append("Email", payload.email);
      mailData.append("Country", payload.country);
      mailData.append("Quantity", `${payload.quantity} ${payload.unit}`);
      mailData.append("Destination Port", payload.destination_port);
      mailData.append("Message", payload.message);
      mailData.append("_subject", `RFQ: ${payload.product} from ${payload.name}`);
      mailData.append("_captcha", "false");
      mailData.append("_cc", "depu.sep13@gmail.com");

      fetch("https://formsubmit.co/ajax/sales@vishnubalajiglobal.com", {
        method: "POST",
        body: mailData,
        headers: { Accept: "application/json" }
      }).catch(function (err) {
        console.warn("Background email notification:", err);
      });

      // 4. Background Supabase Log (using public anon key if configured)
      const supabaseUrl = "https://jvjfzqfbrklmydkaxsjp.supabase.co/rest/v1/inquiries";
      const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2amZ6cWZicmtsbXlka2F4c2pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM2MTcwNjksImV4cCI6MjA5OTE5MzA2OX0.FtzbsNm5VWtcWw1U7xRIXpfm4CPcdoRXzGW1nP5_D-M";

      fetch(supabaseUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
          Prefer: "return=minimal"
        },
        body: JSON.stringify({
          name: payload.name,
          company: payload.company,
          email: payload.email,
          country: payload.country,
          product: payload.product,
          quantity: payload.quantity,
          unit: payload.unit,
          destination_port: payload.destination_port,
          message: payload.message,
          created_at: new Date().toISOString(),
          pipeline_stage: "new"
        })
      }).catch(function (err) {
        console.warn("Supabase logging notice:", err);
      });

      // 5. Provide instant user confirmation
      const successMsg = document.createElement("div");
      successMsg.style.background = "rgba(37, 211, 102, 0.15)";
      successMsg.style.border = "1px solid #25d366";
      successMsg.style.color = "#ffffff";
      successMsg.style.padding = "16px";
      successMsg.style.borderRadius = "8px";
      successMsg.style.marginTop = "16px";
      successMsg.style.fontSize = "0.9rem";
      successMsg.style.lineHeight = "1.5";
      successMsg.innerHTML = `<strong>✔ Quotation Request Received!</strong><br>` +
        `Our export team has been alerted. For immediate pricing, connect directly with Trade Director Sandeep Solanke:<br>` +
        `<div style="margin-top: 10px; display: flex; gap: 8px; flex-wrap: wrap;">` +
        `<a href="${waUrl}" target="_blank" style="display: inline-flex; align-items: center; gap: 6px; background: #25d366; color: #fff; padding: 8px 14px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; text-decoration: none;"><i class="fab fa-whatsapp"></i> Chat on WhatsApp</a> ` +
        `<a href="${mailtoUrl}" style="display: inline-flex; align-items: center; gap: 6px; background: #0d274c; border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 8px 14px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; text-decoration: none;"><i class="fas fa-envelope"></i> Open Email</a>` +
        `</div>`;

      rfqForm.innerHTML = "";
      rfqForm.appendChild(successMsg);
    });
  }
});
